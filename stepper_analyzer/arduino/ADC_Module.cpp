/* Teensy 3.x, LC ADC library
 * https://github.com/pedvide/ADC
 * Copyright (c) 2016 Pedro Villanueva
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/* ADC_Module.cpp: Implements the fuctions of a Teensy 3.x, LC ADC module
 *
 */



#include "ADC_Module.h"
//#include "ADC.h"

// include the internal reference
//#include <VREF.h>


/* Constructor
*   Point the registers to the correct ADC module
*   Copy the correct channel2sc1a
*   Call init
*   The very long initializer list could be shorter using some kind of struct?
*/
ADC_Module::ADC_Module(uint8_t ADC_number, const uint8_t* const a_channel2sc1a, const ADC_NLIST* const a_diff_table):
adc_num(ADC_number),
channel2sc1a(a_channel2sc1a),
diff_table(a_diff_table)
{
    
    //adc_num = ADC_number;
    
    // We don't know what pin is called yet, so just disable all the keepers.  This could cause odd behavior on pins not used for ADC.
    // A rewrite of this library should deal with this in a better way.

    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_02 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_03 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_07 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_06 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_01 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_00 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_10 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_11 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_08 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_09 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B0_12 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B0_13 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_14 &= (FULL32BIT ^ (0x1 << 12));
    IOMUXC_SW_PAD_CTL_PAD_GPIO_AD_B1_15 &= (FULL32BIT ^ (0x1 << 12));
                            

    // call our init
    analog_init();

}

/* Initialize stuff:
*  - Clear all fail flags
*  - Internal reference (default: external vcc)
*  - Mux between a and b channels (b channels)
*  - Calibrate with 32 averages and low speed
*  - When first calibration is done it sets:
*     - Resolution (default: 10 bits)
*     - Conversion speed and sampling time (both set to medium speed)
*     - Averaging (set to 4)
*/
void ADC_Module::analog_init() {

    // default settings:
    /*
        - 10 bits resolution
        - 4 averages
        - vcc reference
        - no interrupts
        - pga gain=1
        - conversion speed = medium
        - sampling speed = medium
    initiate to 0 (or 1) so the corresponding functions change it to the correct value
    */
    analog_res_bits = 0;
    analog_max_val = 0;
    analog_num_average = 0;
    analog_reference_internal = ADC_REF_SOURCE::REF_NONE;
    pga_value = 1;

    conversion_speed = ADC_CONVERSION_SPEED::VERY_HIGH_SPEED; // set to something different from line 139 so it gets changed there
    sampling_speed =  ADC_SAMPLING_SPEED::VERY_HIGH_SPEED;

    calibrating = 0;

    fail_flag = ADC_ERROR::CLEAR; // clear all errors

    num_measurements = 0;


    // set reference to vcc
    setReference(ADC_REFERENCE::REF_3V3);

    // set resolution to 10
    setResolution(10);

    // the first calibration will use 32 averages and lowest speed,
    // when this calibration is over the averages and speed will be set to default by wait_for_cal and init_calib will be cleared.
    init_calib = 1;
    setAveraging(32);
    setConversionSpeed(ADC_CONVERSION_SPEED::LOW_SPEED);
    setSamplingSpeed(ADC_SAMPLING_SPEED::LOW_SPEED);

    // begin init calibration
    calibrate();
}

// starts calibration
void ADC_Module::calibrate() {

    __disable_irq();
    
    calibrating = 1;

    //ADC0_GC[7] = CAL BIT
    //ADC0_GS[1] = CALF BIT
    //ADC0_HS[0] = COCO0 BIT
    //ADC1_HS[0] = COCO0 Bit
    if(adc_num == 0){
        
        //Stop Previous Calibration by setting Bit to 0 (pg 3493)
        ADC1_GC &= FULL32BIT ^ (0x1 << 7);
        
        //Clear Cal Error Bit by writing 1 (pg 3495)
        ADC1_GS |= (0x1 << 1);
        
        //Start Calibration by writing 1 to Cal bit  (pg 3493)
        ADC1_GC |= (0x1 << 7);
        
    }
    
    else if (adc_num == 1){
        
        //Stop Previous Calibration by setting Bit to 0 (pg 3493)
        ADC2_GC &= FULL32BIT ^ (0x1 << 7);
        
        //Clear Cal Error Bit by writing 1 (pg 3495)
        ADC2_GS |= (0x1 << 1);
        
        //Start Calibration by writing 1 to Cal bit  (pg 3493)
        ADC2_GC |= (0x1 << 7);
        
    }
    
    __enable_irq();
}


/* Waits until calibration is finished and writes the corresponding registers
*
*/
void ADC_Module::wait_for_cal(void) {
    
    if(calibrating){
        
        if(adc_num == 0){
            
            while((ADC1_GC >> 7) & 1){
                
                yield();
                
            }
            
            //Not sure if the HS Bit (COCO Flag) is correct/necessary
            if(((ADC1_GS >> 1) & 1) || (ADC1_HS ^ 1)){
                
                fail_flag |= ADC_ERROR::CALIB;
                
            }
            
        }
        
        else if (adc_num == 1){
            
            while((ADC2_GC >> 7) & 1){
                
                yield();
                
            }

            if(((ADC2_GS >> 1) & 1) || (ADC2_HS ^ 1)){
                
                fail_flag |= ADC_ERROR::CALIB;
                
            }
            
        }
        
        calibrating = 0;
        
        if(init_calib){
            
            setConversionSpeed(ADC_CONVERSION_SPEED::MED_SPEED);
            
            setSamplingSpeed(ADC_SAMPLING_SPEED::MED_SPEED);
            
            setAveraging(4);
            
            init_calib = 0;
            
        }
        
    }

}

//! Starts the calibration sequence, waits until it's done and writes the results
/** Usually it's not necessary to call this function directly, but do it if the "environment" changed
*   significantly since the program was started.
*/
void ADC_Module::recalibrate() {

    calibrate();

    wait_for_cal();
}



/////////////// METHODS TO SET/GET SETTINGS OF THE ADC ////////////////////


/* Set the voltage reference you prefer, default is 3.3V
*   It needs to recalibrate
*  Use ADC_REF_3V3, ADC_REF_1V2 (not for Teensy LC) or ADC_REF_EXT
*/
void ADC_Module::setReference(ADC_REFERENCE type) {
    
    if(adc_num == 0){
        
        ADC1_CFG &= FULL32BIT ^ (0x3 << 11);
        
    } else if(adc_num == 1){
        
        ADC2_CFG &= FULL32BIT ^ (0x3 << 11);    
        
    }

    calibrate();
}


/* Change the resolution of the measurement
*  For single-ended measurements: 8, 10, 12 or 16 bits.
*  For differential measurements: 9, 11, 13 or 16 bits.
*  If you want something in between (11 bits single-ended for example) select the inmediate higher
*  and shift the result one to the right.
*
*  It doesn't recalibrate
*/
void ADC_Module::setResolution(uint8_t bits) {

    uint8_t resBits;
    
    if ((adc_num > 1) || (adc_num < 0)){
        //Fail I guess
        return;
        
    }
    
    if (analog_res_bits == bits){
        
        return;
        
    }
    
   // uint8_t resBits = 0;
        
    wait_for_cal();
        
    
    if (bits >11){
        
        analog_res_bits= 12;
        
        resBits = 0x2;
        
        analog_max_val = 4095;
        
    } else if(bits > 9){
        
        analog_res_bits = 10;
        
        resBits = 0x1;
        
        analog_max_val = 1023;
        
    } else {
        
        analog_res_bits  = 8;
        
        resBits = 0;
        
        analog_max_val = 255;
        
    }
    
    if (adc_num == 0){
        
        ADC1_CFG &= (FULL32BIT ^ (0x3 << 2));
        
        ADC1_CFG |= ((resBits & 0x3) << 2);
        
        
    } else if (adc_num == 1){
        
        ADC2_CFG &= (FULL32BIT ^ (0x3 << 2));
        
        ADC2_CFG |= ((resBits & 0x3) << 2);
        
        
    }

}

/* Returns the resolution of the ADC
*
*/
uint8_t ADC_Module::getResolution() {
    return analog_res_bits;
}

/* Returns the maximum value for a measurement, that is: 2^resolution-1
*
*/
uint32_t ADC_Module::getMaxValue() {
    return analog_max_val;
}


// Sets the conversion speed
/* Increase the sampling speed for low impedance sources, decrease it for higher impedance ones.
* \param speed can be any of the ADC_SAMPLING_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED or VERY_HIGH_SPEED.
*
* VERY_LOW_SPEED is the lowest possible sampling speed (+24 ADCK).
* LOW_SPEED adds +16 ADCK.
* MED_SPEED adds +10 ADCK.
* HIGH_SPEED adds +6 ADCK.
* VERY_HIGH_SPEED is the highest possible sampling speed (0 ADCK added).
*/
void ADC_Module::setConversionSpeed(ADC_CONVERSION_SPEED speed) {

    if (speed == conversion_speed){
        
        return;
        
    }
    
    wait_for_cal();
    
    if ( (speed == ADC_CONVERSION_SPEED::ADACK_10) || (speed == ADC_CONVERSION_SPEED::ADACK_20)){
        
            if (adc_num == 0){
                
                ADC1_GC &= FULL32BIT ^ (0x1 << 0);
        
                ADC1_GC |= (0x1 << 0);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 0);
        
                ADC1_CFG |= (0x3 << 0);
            
        
            } else if (adc_num == 1){
        
                ADC2_GC &= FULL32BIT ^ (0x1 << 0);
        
                ADC2_GC |= (0x1 << 0);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 0);
        
                ADC2_CFG |= (0x3 << 0);
        
            }
        
        if ( speed == ADC_CONVERSION_SPEED::ADACK_10) {
            
            if (adc_num == 0){
                
                ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
        
            } else if (adc_num == 1){
        
                ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
        
            }
            
        }
        
        if ( speed == ADC_CONVERSION_SPEED::ADACK_20){
            
            if (adc_num == 0){
        
                ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
                
                ADC1_CFG |= (0x1 << 10);
        
            } else if (adc_num == 1){
        
                ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
                
                ADC2_CFG |= (0x1 << 10);
        
            }
            
        }
        
        conversion_speed = speed;
        
        return;
        
    }
    
    //Disable Async Clock
    if (adc_num == 0){

        ADC1_GC &= FULL32BIT ^ (0x1 << 0);

    } else if (adc_num == 1){

        ADC2_GC &= FULL32BIT ^ (0x1 << 0);

    }
    
    uint32_t ADC_CFG_speed;
    
    if (speed == ADC_CONVERSION_SPEED::VERY_LOW_SPEED){
        
        if (adc_num == 0){
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);
                
            ADC1_CFG |= (0x1 << 7);

        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);
                
            ADC2_CFG |= (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_VERY_LOW_SPEED;
        
    } else if (speed == ADC_CONVERSION_SPEED::LOW_SPEED){
        
        if (adc_num == 0){

            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);
                
            ADC1_CFG |= (0x1 << 7);

        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);
                
            ADC2_CFG |= (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_LOW_SPEED;
        
    } else if (speed == ADC_CONVERSION_SPEED::MED_SPEED){
        
        if (adc_num == 0){

            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);

        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_MED_SPEED;
        
    } else if (speed == ADC_CONVERSION_SPEED::HIGH_SPEED_16BITS){
        
        if (adc_num == 0){

            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG |= (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);
                
        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG |= (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_HI_SPEED_16_BITS;
        
    } else if (speed == ADC_CONVERSION_SPEED::HIGH_SPEED){
        
        if (adc_num == 0){

            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG |= (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);

        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG |= (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_HI_SPEED;
        
    } else if (speed == ADC_CONVERSION_SPEED::VERY_HIGH_SPEED){
        
        if (adc_num == 0){

            ADC1_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC1_CFG |= (0x1 << 10);
            
            ADC1_CFG &= FULL32BIT ^ (0x1 << 7);

        } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x1 << 10);
            
            ADC2_CFG |= (0x1 << 10);
            
            ADC2_CFG &= FULL32BIT ^ (0x1 << 7);

        }
        
        ADC_CFG_speed = ADC_CFG1_VERY_HIGH_SPEED;
        
    } else{
        
     fail_flag |= ADC_ERROR::OTHER;
     
     return;
        
    }
    
    //This will set both ADICLK and ADIV based on ADC_CFG_speed
    if (adc_num == 0){
        
            ADC1_CFG &= FULL32BIT ^ (0x3 << 5);
            
            ADC1_CFG &= FULL32BIT ^ (0x3 << 0);
            
            ADC1_CFG |= ADC_CFG_speed;

    } else if (adc_num == 1){

            ADC2_CFG &= FULL32BIT ^ (0x3 << 5);
            
            ADC2_CFG &= FULL32BIT ^ (0x3 << 0);
            
            ADC2_CFG |= ADC_CFG_speed;

    }
    
    conversion_speed = speed;
    
}


// Sets the sampling speed
/* Increase the sampling speed for low impedance sources, decrease it for higher impedance ones.
* \param speed can be any of the ADC_SAMPLING_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED or VERY_HIGH_SPEED.
*
* VERY_LOW_SPEED is the lowest possible sampling speed (+24 ADCK).
* LOW_SPEED adds +16 ADCK.
* MED_SPEED adds +10 ADCK.
* HIGH_SPEED adds +6 ADCK.
* VERY_HIGH_SPEED is the highest possible sampling speed (0 ADCK added).
*/
void ADC_Module::setSamplingSpeed(ADC_SAMPLING_SPEED speed) {

        wait_for_cal();
    
    switch(speed){
        
        case ADC_SAMPLING_SPEED::VERY_LOW_SPEED:
            
            //ADLSMP = 1 //ADC1_CFG[4]
            //ADLSTS = 0 //ADC1_CFG[9-8]
            // +24 ADCK
            
            if (adc_num == 0){
                
                ADC1_CFG |= (0x1 << 4);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC1_CFG |= (0x3 << 8);
                
            }
            
            else if (adc_num == 1){
                
                ADC2_CFG |= (0x1 << 4);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC2_CFG |= (0x3 << 8);
                
            }
            
            break;
            
        case ADC_SAMPLING_SPEED::LOW_SPEED:
            
         //   ADLSMP = 1
          //  ADLSTS = 1
         //   +16 ADCK
            
            if (adc_num == 0){
                
                ADC1_CFG |= (0x1 << 4);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC1_CFG |= (0x1 << 8);
                
            }
            
            else if (adc_num == 1){
                
                ADC2_CFG |= (0x1 << 4);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC2_CFG |= (0x1 << 8);
                
            }
            
            break;
            
        case ADC_SAMPLING_SPEED::MED_SPEED:
            
         //   ADLSMP = 1
         //   ADLSTS = 2
         //   +12 ADCK
            
            if (adc_num == 0){
                
                ADC1_CFG |= (0x1 << 4);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 8);
                
            }
            
            else if (adc_num == 1){
                
                ADC2_CFG |= (0x1 << 4);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 8);
                
            }
            
            break;
            
        case ADC_SAMPLING_SPEED::HIGH_SPEED:
            
         //   ADLSMP = 1
         //   ADLSTS = 3
         //   +6 ADCK
            
            if (adc_num == 0){
                
                ADC1_CFG &= FULL32BIT ^ (0x1 << 4);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC1_CFG |= (0x1 << 9);
                
            }
            
            else if (adc_num == 1){
                
                ADC2_CFG &= FULL32BIT ^ (0x1 << 4);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 8);
                
                ADC2_CFG |= (0x1 << 9);
                
            }
            
            break;
            
        case ADC_SAMPLING_SPEED::VERY_HIGH_SPEED:
            
        //    ADLSMP = 0
         //   ADLSTS = 0
         //   +2 ADCK
            
            if (adc_num == 0){
                
                ADC1_CFG &= FULL32BIT ^ (0x1 << 4);
                
                ADC1_CFG &= FULL32BIT ^ (0x3 << 8);

                
            }
            
            else if (adc_num == 1){
                
                ADC2_CFG |= (0x1 << 4);
                
                ADC2_CFG &= FULL32BIT ^ (0x3 << 8);
                
            }
            
            break;
            
    }
    
    sampling_speed = speed;
    
}


/* Set the number of averages: 0, 4, 8, 16 or 32.
*
*/
void ADC_Module::setAveraging(uint8_t num) {
    
    if ((adc_num > 1) || (adc_num < 0)){
        //Fail I guess
        return;
        
    }
    
    if (analog_num_average == num){
        
        return;
        
    }
    
    uint8_t avgNum = 0;
        
    wait_for_cal();
        
    
    if (num > 16){
        
        analog_num_average = 32;
        
        avgNum = 3;
        
    } else if(num > 8){
        
        analog_num_average  = 16;
        
        avgNum = 2;
        
    } else if (num > 4){
        
        analog_num_average  = 8;
        
        avgNum = 1;
        
    } else if (num > 0){
        
        analog_num_average  = 4;
        
        avgNum = 0;
        
    } else {
        
     analog_num_average = 0;
     
     avgNum = 0;
     
    }
     
//      if (adc_num == 0){
//          
//         ADC1_GC &= FULL32BIT ^ (0x1 << 5);
//         
//         //ADC2_GC |= (0x1 << 0)
//         
//      }
//      
//      if (adc_num == 1){
//      
//         ADC2_GC &= FULL32BIT ^ (0x1 << 5);
//         
//     }
    
    if (adc_num == 0){
        
        ADC1_GC &= FULL32BIT ^ (0x1 << 5);
        
        if (analog_num_average > 0){
            
            ADC1_GC |= (0x1 << 5);
            
        }
        
        ADC1_GC &= FULL32BIT ^ (0x3 << 14);
        
        ADC1_GC |= (avgNum << 14);
        
        ADC1_CFG &= FULL32BIT ^ (0x3 << 14);

        ADC1_CFG |= ((avgNum & 0x03) << 14);
        
        
    } else if (adc_num == 1){

        ADC2_GC &= FULL32BIT ^ (0x1 << 5);
        
        if (analog_num_average > 0){
            
            ADC2_GC |= (0x1 << 5);
            
        }
        
        ADC2_GC &= FULL32BIT ^ (0x3 << 14);
        
        ADC2_CFG &= FULL32BIT ^ (0x3 << 14);

        ADC2_CFG |= ((avgNum & 0x03) << 14);
        
    }
    
}


/* Enable interrupts: An ADC Interrupt will be raised when the conversion is completed
*  (including hardware averages and if the comparison (if any) is true).
*/

void ADC_Module::enableInterrupts() {
   
    wait_for_cal();
    
    if(adc_num == 0){
        
        ADC1_HC0 |= (0x1 << 7);
               
        attachInterruptVector(IRQ_ADC1, adc0_isr);
        
        NVIC_ENABLE_IRQ(IRQ_ADC1);
        
    }
    
    else if(adc_num == 1){
        
        ADC2_HC0 |= (0x1 << 7);
        
        attachInterruptVector(IRQ_ADC2, adc1_isr);
        
        NVIC_ENABLE_IRQ(IRQ_ADC2);
        
    }
    
}

/* Disable interrupts
*
*/
void ADC_Module::disableInterrupts() {
    
    if(adc_num == 0){
        
        ADC1_HC0 &= FULL32BIT ^ (0x1 << 7);
        
        NVIC_DISABLE_IRQ(IRQ_ADC1);
        
    }
    
    else if(adc_num == 1){
        
        ADC2_HC0 &= FULL32BIT ^ (0x1 << 7);
        
        NVIC_DISABLE_IRQ(IRQ_ADC2);
        
    }
    
}


/* Enable DMA request: An ADC DMA request will be raised when the conversion is completed
*  (including hardware averages and if the comparison (if any) is true).
*/
void ADC_Module::enableDMA() {
    
    wait_for_cal();
    
    //ADC_GC[1]
    
    if(adc_num == 0){
        
        ADC1_GC |= (0x1 << 1);
        
        
    }
    
    else if(adc_num == 1){
        
        ADC2_GC |= (0x1 << 1);
        
        
    }
    
}

/* Disable ADC DMA request
*
*/
void ADC_Module::disableDMA() {
    
    if(adc_num == 0){
        
        ADC1_GC &= FULL32BIT ^ (0x1 << 1);
        
        
    }
    
    else if(adc_num == 1){
        
        ADC2_GC &= FULL32BIT ^ (0x1 << 1);
        
        
    } 
    
}


/* Enable the compare function: A conversion will be completed only when the ADC value
*  is >= compValue (greaterThan=1) or < compValue (greaterThan=0)
*  Call it after changing the resolution
*  Use with interrupts or poll conversion completion with isADC_Complete()
*/
void ADC_Module::enableCompare(int16_t compValue, bool greaterThan) {
    
    //ADC_GC[4]
    
    wait_for_cal();
    
    if(adc_num == 0){
        
        ADC1_GC |= (0x1 << 4);
        
        if(greaterThan){
        
            ADC1_GC |= (0x1 << 3);
            
        }
        
        else {
            
            ADC1_GC &= FULL32BIT ^ (0x1 << 3);
            
        }
        
        ADC1_GC &= FULL32BIT ^ (0x1 << 2);
        
        ADC1_CV |= (0x0FFF & compValue);
        
    }
    
    else if(adc_num == 1){
        
        ADC2_GC |= (0x1 << 4);
        
        if(greaterThan){
        
            ADC2_GC |= (0x1 << 3);
            
        }
        
        else {
            
            ADC2_GC &= FULL32BIT ^ (0x1 << 3);
            
        }
        
        ADC2_GC &= FULL32BIT ^ (0x1 << 2);
        
        ADC2_CV |= (0x0FFF & compValue);
        
    }
    
}

/* Enable the compare function: A conversion will be completed only when the ADC value
*  is inside (insideRange=1) or outside (=0) the range given by (lowerLimit, upperLimit),
*  including (inclusive=1) the limits or not (inclusive=0).
*  See Table 31-78, p. 617 of the freescale manual.
*  Call it after changing the resolution
*/
void ADC_Module::enableCompareRange(int16_t lowerLimit, int16_t upperLimit, bool insideRange, bool inclusive) {
    
    wait_for_cal();
    
    if(adc_num == 0){
        
        ADC1_GC |= (0x1 << 4);
        
        ADC1_GC |= (0x1 << 2);
        
        if(inclusive){
        
            ADC1_GC |= (0x1 << 3);
            
        if(insideRange){
            
            ADC1_CV |= (0x0FFF << 16);
            ADC1_CV &= ((0x0FFF & upperLimit) << 16);
            
            
            ADC1_CV |= 0x0FFF;
            ADC1_CV &= ((0x0FFF & lowerLimit));
            
        }
        
        else {
            
            ADC1_CV |= (0x0FFF << 16);
            ADC1_CV &= ((0x0FFF & lowerLimit) << 16);
            
            
            ADC1_CV |= 0x0FFF;
            ADC1_CV &= ((0x0FFF & upperLimit));
            
        }
            
        }
        
        else {
            
            ADC1_GC &= FULL32BIT ^ (0x1 << 3);
            
            if(insideRange){
            
                ADC1_CV |= (0x0FFF << 16);
                ADC1_CV &= ((0x0FFF & lowerLimit) << 16);
                
                
                ADC1_CV |= 0x0FFF;
                ADC1_CV &= ((0x0FFF & upperLimit));
                
            }
            
            else {
                
                ADC1_CV |= (0x0FFF << 16);
                ADC1_CV &= ((0x0FFF & upperLimit) << 16);
                
                
                ADC1_CV |= 0x0FFF;
                ADC1_CV &= ((0x0FFF & lowerLimit));
                
            }
            
        }
        
    }
    
    else if(adc_num == 1){
        
        ADC2_GC |= (0x1 << 4);
        
        ADC2_GC |= (0x1 << 2);
        
        if(inclusive){
        
            ADC2_GC |= (0x1 << 3);
            
        if(insideRange){
        
            ADC2_CV |= (0x0FFF << 16);
            ADC2_CV &= ((0x0FFF & upperLimit) << 16);
            
            
            ADC2_CV |= 0x0FFF;
            ADC2_CV &= ((0x0FFF & lowerLimit));
            
        }
        
        else {
            
            ADC2_CV |= (0x0FFF << 16);
            ADC2_CV &= ((0x0FFF & lowerLimit) << 16);
            
            
            ADC2_CV |= 0x0FFF;
            ADC2_CV &= ((0x0FFF & upperLimit));
            
        }
            
        }
        
        else {
            
            ADC2_GC &= FULL32BIT ^ (0x1 << 3);
            
            if(insideRange){
            
                ADC2_CV |= (0x0FFF << 16);
                ADC2_CV &= ((0x0FFF & lowerLimit) << 16);
                
                
                ADC2_CV |= 0x0FFF;
                ADC2_CV &= ((0x0FFF & upperLimit));
                
            }
            
            else {
                
            ADC2_CV |= (0x0FFF << 16);
            ADC2_CV &= ((0x0FFF & upperLimit) << 16);
            
            
            ADC2_CV |= 0x0FFF;
            ADC2_CV &= ((0x0FFF & lowerLimit));
                
            }
            
        }
        
        //ADC2_CV[27:16] = 0x00000FFF & upperLimit
        //ADC2_CV[11:0] = 0x00000FFF & lowerLimit  // I don't think these should be here...
        
    }    
    
}

/* Disable the compare function
*
*/
void ADC_Module::disableCompare() {
    
    if(adc_num == 0){
        
        ADC1_GC &= FULL32BIT ^ (0x1 << 4);
            
        ADC1_GC &= FULL32BIT ^ (0x1 << 3);
        
        ADC1_GC &= FULL32BIT ^ (0x1 << 2);
        
    }
    
    else {
        
        ADC2_GC &= FULL32BIT ^ (0x1 << 4);
            
        ADC2_GC &= FULL32BIT ^ (0x1 << 3);
        
        ADC2_GC &= FULL32BIT ^ (0x1 << 2);
        
    }
    
}

/* Enables the PGA and sets the gain
*   Use only for signals lower than 1.2 V
*   \param gain can be 1, 2, 4, 8, 16 32 or 64
*
*/
void ADC_Module::enablePGA(uint8_t gain) {
    
    //Only exists to not break the program if someone tries to use it
    
    return;
    
}

/* Returns the PGA level
*  PGA level = from 0 to 64
*/
uint8_t ADC_Module::getPGA() {
    return pga_value;
}

//! Disable PGA
void ADC_Module::disablePGA() {
#if ADC_USE_PGA
    
    //Only exists to not break the program if someone tries to use it
    
    return;
    
#endif
    pga_value = 1;
}


//////////////// INFORMATION ABOUT VALID PINS //////////////////

// check whether the pin is a valid analog pin
bool ADC_Module::checkPin(uint8_t pin) {
    
    if(pin > ADC_MAX_PIN){
     
        return(false);
        
    }
    
    const uint8_t sc1a_pin = channel2sc1a[pin];
    
    if( (sc1a_pin & ADC_SC1A_CHANNELS) == ADC_SC1A_PIN_INVALID){
        
            return(false);
        
    }
    
    return(true);
    
}

// check whether the pins are a valid analog differential pins (including PGA if enabled)
bool ADC_Module::checkDifferentialPins(uint8_t pinP, uint8_t pinN) {
    
    //TEENSY 4.0 has no Differential Pins
    return(false);    
    
}


//////////////// HELPER METHODS FOR CONVERSION /////////////////

// Starts a single-ended conversion on the pin (sets the mux correctly)
// Doesn't do any of the checks on the pin
// It doesn't change the continuous conversion bit
void ADC_Module::startReadFast(uint8_t pin) {
    
  const uint8_t sc1a_pin = channel2sc1a[pin];
  
  
  __disable_irq();
  
  if(adc_num == 0){
  
    ADC1_HC0 &= FULL32BIT ^ (0x1F << 0);
    
    ADC1_HC0 |= sc1a_pin;
    
  }
  else if (adc_num == 1){
      
    ADC2_HC0 &= FULL32BIT ^ (0x1F << 0);
    
    ADC2_HC0 |= sc1a_pin;
      
  }
  
  __enable_irq();
  
  
}

// Starts a differential conversion on the pair of pins
// Doesn't do any of the checks on the pins
// It doesn't change the continuous conversion bit
void ADC_Module::startDifferentialFast(uint8_t pinP, uint8_t pinN) {
    
    //TEENSY 4.0 has no Differential Pins
    return;
    
}



//////////////// BLOCKING CONVERSION METHODS //////////////////
/*
    This methods are implemented like this:

    1. Check that the pin is correct
    2. if calibrating, wait for it to finish before modifiying any ADC register
    3. Check if we're interrupting a measurement, if so store the settings.
    4. Disable continuous conversion mode and start the current measurement
    5. Wait until it's done, and check whether the comparison (if any) was succesful.
    6. Get the result.
    7. If step 3. is true, restore the previous ADC settings

*/


/* Reads the analog value of the pin.
* It waits until the value is read and then returns the result.
* If a comparison has been set up and fails, it will return ADC_ERROR_VALUE.
* Set the resolution, number of averages and voltage reference using the appropriate functions.
*/


int ADC_Module::analogRead(uint8_t pin){
    
    if(!checkPin(pin)){
        
        fail_flag |= ADC_ERROR::WRONG_PIN;
        
        return(ADC_ERROR_VALUE);
        
    }
    
    num_measurements++;
    
    wait_for_cal();
    
    ADC_Config old_config = {0};
    
    const uint8_t wasADCInUse = isConverting();
    
    if(wasADCInUse){
        
        __disable_irq();
        
        saveConfig(&old_config);
        
        __enable_irq();
        
    }
    
    singleMode();
    
    startReadFast(pin);
    
    while(isConverting()){
        
        yield();
        
    }
    
    int32_t result = 0;
    
    __disable_irq();
    
    if(isComplete()){
        
        if(adc_num == 0){
            
            result = (int16_t)(int32_t)(ADC1_R0);
            
        }
        
        else if(adc_num == 1){
            
            result = (int16_t)(int32_t)(ADC2_R0);
            
        }
        
    }
    
    else{
        
        fail_flag |= ADC_ERROR::COMPARISON;
        
        result = ADC_ERROR_VALUE;
        
    }
    
    __enable_irq();
    
    if(wasADCInUse){
        
        __disable_irq();
        
        loadConfig(&old_config);
        
        __enable_irq();
        
    }
    
    num_measurements--;
    
    return(result);
    
} // analogRead



/* Reads the differential analog value of two pins (pinP - pinN)
* It waits until the value is read and then returns the result
* If a comparison has been set up and fails, it will return ADC_ERROR_DIFF_VALUE
* Set the resolution, number of averages and voltage reference using the appropriate functions
*/
int ADC_Module::analogReadDifferential(uint8_t pinP, uint8_t pinN) {
    
    if (!checkDifferentialPins(pinP, pinN)){
        
            fail_flag |= ADC_ERROR::WRONG_PIN;
            
            return ADC_ERROR_VALUE;
        
    } else {
        
        return(0);
        
    }
    
} // analogReadDifferential



/////////////// NON-BLOCKING CONVERSION METHODS //////////////
/*
    This methods are implemented like this:

    1. Check that the pin is correct
    2. if calibrating, wait for it to finish before modifiying any ADC register
    3. Check if we're interrupting a measurement, if so store the settings (in a member of the class, so it can be accessed).
    4. Disable continuous conversion mode and start the current measurement

    The fast methods only do step 4.

*/


/* Starts an analog measurement on the pin.
*  It returns inmediately, read value with readSingle().
*  If the pin is incorrect it returns false.
*/
bool ADC_Module::startSingleRead(uint8_t pin) {
    
    if(!checkPin(pin)){
        
        fail_flag |= ADC_ERROR::WRONG_PIN;
        
        return(false);
        
    }
    
    wait_for_cal();
    
    adcWasInUse = isConverting();
    
    if(adcWasInUse){
        
        __disable_irq();
        
        saveConfig(&adc_config);
        
        __enable_irq();
        
    }
    
    singleMode();
    
    startReadFast(pin);
    
    return(true);
    
}


/* Start a differential conversion between two pins (pinP - pinN).
* It returns inmediately, get value with readSingle().
* Incorrect pins will return false.
* Set the resolution, number of averages and voltage reference using the appropriate functions
*/
bool ADC_Module::startSingleDifferential(uint8_t pinP, uint8_t pinN) {
    
    if (!checkDifferentialPins(pinP, pinN)){
        
        fail_flag |= ADC_ERROR::WRONG_PIN;
            
        return false;
        
    }
    
    return false;
    
}



///////////// CONTINUOUS CONVERSION METHODS ////////////
/*
    This methods are implemented like this:

    1. Check that the pin is correct
    2. If calibrating, wait for it to finish before modifiying any ADC register
    4. Enable continuous conversion mode and start the current measurement

*/

/* Starts continuous conversion on the pin
 * It returns as soon as the ADC is set, use analogReadContinuous() to read the values
 * Set the resolution, number of averages and voltage reference using the appropriate functions BEFORE calling this function
*/
bool ADC_Module::startContinuous(uint8_t pin) {
    
    if(!checkPin(pin)){
        
        fail_flag |= ADC_ERROR::WRONG_PIN;
        
        return(false);
        
    }
    
    wait_for_cal();
    
    num_measurements++;
    
    continuousMode();
    
    startReadFast(pin);
    
    return(true);
     
}


/* Starts continuous and differential conversion between the pins (pinP-pinN)
 * It returns as soon as the ADC is set, use analogReadContinuous() to read the value
 * Set the resolution, number of averages and voltage reference using the appropriate functions BEFORE calling this function
*/
bool ADC_Module::startContinuousDifferential(uint8_t pinP, uint8_t pinN) {
    
    if (!checkDifferentialPins(pinP, pinN)){
        
        fail_flag |= ADC_ERROR::WRONG_PIN;
        
        return false;
        
    }
    
    return false;
    
}


/* Stops continuous conversion
*/
void ADC_Module::stopContinuous() {
    
    if(adc_num == 0){
    
        ADC1_HC0 |= 0x1F;
        
    }
    else if (adc_num == 1){
        
        ADC2_HC0 |= 0x1F;
        
    }

    if(!num_measurements){
        
        num_measurements--;
        
    }
    
    return;
}


void SetBit(volatile uint32_t& Register, uint32_t Bit, uint8_t Position){

    if (Position > 32){
    
        return;
    
    }

    else if (Bit > ((uint32_t)1 << Position)){
        
        return;
        
    }
    
    else {
        
        Register &= FULL32BIT ^ (Bit << Position);
        
        Register |= (Bit << Position);
        
        
    }


}

void ClearBit(volatile uint32_t& Register, uint8_t BitSize, uint8_t Position){

    if (Position > 32){
    
        return;
    
    }

    else if (BitSize > Position){
        
        return;
        
    }
    
    else {
        
        Register &= FULL32BIT ^ (((2 << BitSize) - 1) << Position);
            
    }
    
    
}
uint16_t upperCount1;
int32_t Upper1;   
int32_t  Lower1;          
uint16_t lowerCount1;     
uint32_t RunningSum1;
uint8_t DummyCount1;



// uint16_t upperCount2;
// int32_t Upper2;   
// int32_t Lower2;          
// uint16_t lowerCount2;     
// uint32_t RunningSum2;
// uint8_t DummyCount2;


void QT4_ISR1(void){                                     
    
    if (RunningSum1 < 0){

        TMR4_CMPLD10 = upperCount1;
        RunningSum1 += Upper1;

    } else {

        TMR4_CMPLD10 = lowerCount1;
        RunningSum1 += Lower1;

    }

    //ClearISR
    TMR4_SCTRL0 &= (0xFFFF ^ (0x1 << 15));
        
    ADC1_HC0 |= ADC1_HC0;
    
    ADC2_HC0 |= ADC2_HC0;
        
    
    DummyCount1 = 0;  //Memory write to ensure ISR Clear

}
    
// void QT4_ISR2(void){                                     
//     
//     if (RunningSum2 < 0){
// 
//         TMR4_CMPLD10 = upperCount2;
//         RunningSum2 += Upper2;
// 
//     } else {
// 
//         TMR4_CMPLD10 = lowerCount2;
//         RunningSum2 += Lower2;
// 
//     }
// 
//     //ClearISR
//     TMR4_SCTRL0 &= (0xFFFF ^ (0x1 << 15));
//         
//         ADC2_HC0 |= ADC2_HC0;
//     
//     DummyCount2 = 0;  //Memory write to ensure ISR Clear
// 
// }





//////////// PDB ////////////////
//// Only works for Teensy 3.0 and 3.1, not LC (it doesn't have PDB)

#if ADC_USE_PDB

// frequency in Hz
void ADC_Module::startPDB(uint32_t freq) {
    
    CCM_CCGR6 |= (0x3 << 16);  //Clock is on during all modes except STOP.
    
    //USE TIMER4, CHANNEL 0 FOR AS ARBITRARY CHOICE
    TMR4_CTRL0 &= (0xFFFF ^ (0x7 << 13)); //Stops the timer
    TMR4_ENBL &= (0xFFFF ^ 0xF); //Disables the timer on all channels.
   
    uint32_t QTimerClock = 150000000; //Can I pull this from one of the core*.h?
    uint32_t MagFact = 300000000; //A large number at least twice as large as QTimerClock to magnify a decimal and turn it into an int.  The size makes it so we won't lose more resolution on our calculations than exists in the clock.
    // Of course, the current size of MagFact only works for 150MHz.  The Clock Divide will eat into the precision.
    uint8_t clockDivide = 1;
    
    if (freq > QTimerClock) { //Clearly this will work at 150MHz...
        
        return;
        
    } else if (freq < 20){
        
        return; //Too slow
        
    } else if (freq < 40) {
        
        //TMR4_CTRL0[9:12] = 1111
        clockDivide = 128;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9)); //Clear Bits
        TMR4_CTRL0 |= (0xF << 9); // Set Bits

        
    } else if (freq < 80) {
        
        //TMR4_CTRL0[9:12] = 1110
        //Clock Divide to 64
        clockDivide = 64;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0xE << 9);
        
    } else if (freq < 150) {
        
        //TMR4_CTRL0[9:12] = 1101
        //Clock Divide to 32
        clockDivide = 32;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0xD << 9);
        
    } else if (freq < 300) {
        
        //TMR4_CTRL0[9:12] = 1100
        //Clock Divide to 16
        clockDivide = 16;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0xC << 9);
        
    } else if (freq < 600) {
        
        //TMR4_CTRL0[9:12] = 1011
        //Clock Divide to 8
        clockDivide = 8;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0xB << 9);
        
    } else if (freq < 1200) {
        
        //TMR4_CTRL0[9:12] = 1010
        //Clock Divide to 4
        clockDivide = 4;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0xA << 9);
        
    } else if (freq < 2500){
        
        //TMR4_CTRL0[9:12] = 1001
        //Clock Divide to 2
        clockDivide = 2;
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0x9 << 9);
        
    } else {
        
        //TMR4_CTRL0[9:12] = 1000
        //Clock Divide to 1
        TMR4_CTRL0 &= (0xFFFF ^ (0xF << 9));
        TMR4_CTRL0 |= (0x8 << 9);
        
    }
    
    // The theory of this is that we choose a desired frequency to tick the ADC at.  The Quad Timer can only tick in integer increments of 1/150MHz (6.67 ns).
    // We first determine the upper speed bound, that is what is the integer number of clock ticks that would be just too fast to measure our desired frequency.
    // We will fire the ADC too fast until we are too far ahead of the desired frequency, and then we will fire the ADC too slowly until it slows down too much, and back again.
    // Over the course of many cycles, we will on average, fire the ADC the appropriate number of times for our frequency.  We need to alternate the fast and slow ticks so that 
    // our error from the desired frequency and the actual frequency is never more than a single cycle of the Quad Timer frequency with the appropriate division.  It should be 
    // possible to make sure it never deviates by +/- 1/2 cycle for most frequencies, but right now I just want it to work.  The new cycle time is calculated in the Compare ISR
    // Which is put into the Compare Load register so that the next cycle is calculated and ready.  The ISR also fires the ADC.
    //
    //Example
    // If our desired frequency is 62.5MHz, then 150/62.5 = 2.4, so 2 is our upper bound.  3 is then our lower bound.  The lower bound will always be 1 more than the upper bound.
    // We use the decimcal part of the fraction to determine our ratio of fast pulses to slow pulses.  In our case, 60% of the pulses should be fast, and 40% should be slow.
    // Everytime we implement a fast cycle, we increment up by .4, and everytime we implement a slow cycle we decrement by .6.  If our running total is above 0 then the next
    // cycle will be slow, otherwise it will be fast.  Since we increase slower than we decrease, we expect that more faster cycles will occur than slower cycles.
    // By multiplying this ratio by a large number, we can convert it into an int that has enough precision to cover the 150MHz precision of the clock. So instead of 
    // incrementing by .4/.6, we can increment 120,000,000/180,000,000.
    // There are probably better estimates for the cycles, but I thought this would be fast and good enough for now.
    
    
    
   // if (ADC_Module::adc_num == 0){
        
        double wholeRatio = ((double) QTimerClock) / ((double) freq * (double) clockDivide);  // Ratio of the clock and the desired frequency.
        
        upperCount1 = floor(wholeRatio);                                // The integer part of the ratio gives the upper bound of clock ticks for the desired frequency. (fast)
        
        double ratio = wholeRatio - upperCount1;                        // The decimal remainder of the ratio.  This is the target we will aim to achieve with our alternating timer counts
        
        Upper1 = round(MagFact * ratio);                                // Get the Upper Int
        
        Lower1 = Upper1 - MagFact;                                       // The Lower Int
        
        lowerCount1 = upperCount1 + 1;                                   // The lower bound of clock ticks (slow)
        
        TMR4_COMP10 = upperCount1;                                      // Compare Register 1  0xFFFF, it always starts off as fast

        TMR4_CMPLD10 = lowerCount1;                                     // Compare 1 Load Register 0xFFFF, the second one will always be slow.
        
        RunningSum1 = Upper1 + Lower1;                                    // Current Running sum to modify.
        
        
        
        //setHardwareTrigger(); // trigger ADC with hardware, still using swtrigger for T4 fake PDB.  Can try HW if this doesn't work.
        
        attachInterruptVector(IRQ_QTIMER4, QT4_ISR1);
        
        
//     } else if (ADC_Module::adc_num == 1){
//         
//         double wholeRatio = ((double) QTimerClock) / ((double) freq * (double) clockDivide);  // Ratio of the clock and the desired frequency.
//         
//         upperCount2 = floor(wholeRatio);                                // The integer part of the ratio gives the upper bound of clock ticks for the desired frequency. (fast)
//         
//         double ratio = wholeRatio - upperCount2;                        // The decimal remainder of the ratio.  This is the target we will aim to achieve with our alternating timer counts
//         
//         Upper2 = round(MagFact * ratio);                                // Get the Upper Int
//         
//         Lower2 = Upper2 - MagFact;                                       // The Lower Int
//         
//         lowerCount2 = upperCount2 + 1;                                   // The lower bound of clock ticks (slow)
//         
//         TMR4_COMP10 = upperCount2;                                      // Compare Register 1  0xFFFF, it always starts off as fast
// 
//         TMR4_CMPLD10 = lowerCount2;                                     // Compare 1 Load Register 0xFFFF, the second one will always be slow.
//         
//         RunningSum2 = Upper2 + Lower2;                                    // Current Running sum to modify.
//         
//         
//         
//         //setHardwareTrigger(); // trigger ADC with hardware, still using swtrigger for T4 fake PDB.  Can try HW if this doesn't work.
//         
//         attachInterruptVector(IRQ_QTIMER3, QT4_ISR2);
//         
//         
//     }
    
    NVIC_ENABLE_IRQ(IRQ_QTIMER4);
    
    //To Find in i.MX RT1060 Reference, search "TMRx_CSCTRLn", "TMRx_FILTn", "TMRx_DMAn", "TMRx_SCTRL", "TMRx_CTRLn", or "TMRx_ENBL"  Currently starts on Page 3125
    
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x3 << 14));     //normal Operations during debug 
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 13));     //Fault input disabled
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 12));     //Alt-Load disabled
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 11));     //Reload on Capture disabled, doesn't really matter
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 7));      //Compare2 Interrupt Disabled
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 6));      //Compare1 Interrupt Disabled
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 5));      //Compare2 Interrupt Flag
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 4));      //Compare1 Interrupt Flag
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x3 << 2));      //Compare load 2 is never preloaded 
    TMR4_CSCTRL0 &= (0xFFFF ^ (0x1 << 1));      //See Bit 0
    TMR4_CSCTRL0 |= (0x1);                      //Compare load 1 is preloaded on successful compare1
    
    TMR4_FILT0 &= (0xFFFF ^ (0xFF));            //Bypass input filter
    
    TMR4_DMA0 &= (0xFFFF ^ (0x7));              //Disables DMA transfers to CMPLD.  Might want to look at this in the future
    
    TMR4_SCTRL0 &= (0xFFFF ^ 0x3FFF);            //Various interrupts and options disabled
    TMR4_SCTRL0 &= (0xFFFF ^ (0x1 << 15));       //Compare Flag, high is compare occured
    TMR4_SCTRL0 |= (0x1 << 14);                  //Compare Interrupt Enable
    
    
    TMR4_CTRL0 &= (0xFFFF ^ (0x1 << 6));        //Continuous Operation
    TMR4_CTRL0 |= (0x1 << 5);                   //Count until Compare, rollover, load new compare from load register
    TMR4_CTRL0 &= (0xFFFF ^ (0x1 << 4));        //Count up
    TMR4_CTRL0 &= (0xFFFF ^ (0x1 << 3));        //Disable CoChannel Init
    TMR4_CTRL0 &= (0xFFFF ^ (0x7));             //Output is high
    
    
    
    TMR4_ENBL |= 0x1;                           //Enables the timer on channel 0.  This means channels 1-3 have been disabled by this module.  May be unwanted.
    TMR4_CTRL0 |= (0x1 << 13);                  //Starts the timer
    

}

void ADC_Module::stopPDB() {
    
    if (!((CCM_CCGR6 & (0x3 << 16)) >> 16 )) { // if PDB clock wasn't on, return
        
        //setSoftwareTrigger();
        
        return;
    }
    
    TMR4_CTRL0 &= (0xFFFF ^ (0x7 << 13)); //Stops the timer
    TMR4_ENBL &= (0xFFFF ^ 0xF); //Disables the timer on all channels.

    //setSoftwareTrigger();

    NVIC_DISABLE_IRQ(IRQ_QTIMER4);
}

//! Return the PDB's frequency
uint32_t ADC_Module::getPDBFrequency() {
    
    //this whole thing is rather wonky
    uint32_t QTimerClock = 150000000; //Can I pull this from one of the core*.h?
    uint32_t MagFact = 300000000;
    uint8_t ClkDiv = 1;
    uint32_t ClkBin = 1 << ((0x1 & ((TMR4_CTRL0 & (0xF << 9)) >> 11))*4 + (0x1 & ((TMR4_CTRL0 & (0xF << 9)) >> 10))*2 + (0x1 & ((TMR4_CTRL0 & (0xF << 9)) >> 9)));
    
    ClkDiv = ClkBin;
    double Dfreq = 0;
    
    //if (ADC_Module::adc_num == 0){
        
        Dfreq = (double)(QTimerClock)/((((double)Upper1) / ((double) MagFact)) + (double) upperCount1 * (double) ClkDiv);
        
    //} else if (ADC_Module::adc_num == 1){
        
     //   Dfreq = (double)(QTimerClock)/((((double)Upper2) / ((double)MagFact)) + (double) upperCount2 * (double) ClkDiv);
        
    //}
    
    uint32_t freq = round(Dfreq);
    
    return freq;
}



#endif

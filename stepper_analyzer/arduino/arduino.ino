// Skeleton program for reading two input analog channels.
// Tested on Teensy 3.2, 96MHZ (overclocked)

#include <stdio.h>
//#include <ADC.h>
#include <Bounce.h>
//#include <FrequencyTimer2.h>
#include<TimerOne.h>


#include <ST7735_t3.h> // Hardware-specific library

#define TFT_SCLK 13  // SCLK (also LED_BUILTIN so don't use it) Can be 14 on T3.2
#define TFT_MOSI 11  // MOSI can also use pin 7
#define TFT_CS   10  // CS & DC can use pins 2, 6, 9, 10, 15, 20, 21, 22, 23
#define TFT_DC    9  //   but certain pairs must NOT be used: 2+10, 6+9, 20+23, 21+22
#define TFT_RST   8  // RST can use any pin

// ADC count for i=0 (1.5v of 3.3V full scale)
const uint16_t VAL1_OFFSET = 1902;
const uint16_t VAL2_OFFSET = 1860;

// 12 bit -> 4096 counts.
// 3.3V full scale.
// 0.2V per AMP (for +/- 5A sensor).
const float COUNTS_PER_AMP = 0.2 * 4096 / 3.3;

// Non energized limit, with hysteresis.
const int NON_ENERGIZED1 = 100;
const int NON_ENERGIZED2 = 120;

static const int adc1_pin = A9;  // = 23
static const int adc2_pin = A3;  // = 17

static const uint8_t adc1_pin_channel = 14;  
static const uint8_t adc2_pin_channel = 11;  


static const int LED1 = 1;
static const int LED2 = 2;
static const int LED3 = 3;

static const int PUSH_BUTTON1 = 18;
static const int PUSH_BUTTON2 = 19;

static Bounce push_button1 = Bounce(PUSH_BUTTON1, 10);  // 10 ms debounce
static Bounce push_button2 = Bounce(PUSH_BUTTON2, 10);  // 10 ms debounce

static ST7735_t3 tft(TFT_CS, TFT_DC, TFT_MOSI, TFT_SCLK, TFT_RST);

const int MAX_CAPTURE_SIZE = 500;
static int16_t capture[MAX_CAPTURE_SIZE][2];

struct IsrStatus {
  public:
    IsrStatus() :
      isr_count(0), adc_val1(0), adc_val2(0),
      is_energized(false), non_energized_count(0), quadrant(0), full_steps(0), quadrature_errors(0), capture_size(0) {}
    // Number of isr invocactions so far. Overlofw is normal.
    uint32_t isr_count;
    // Signed adc current readings. For a 200mv/A current sensor, units
    // are (0.2V * 4095)/3.3V = 248 counts/A.
    int  adc_val1;
    int  adc_val2;
    bool is_energized;
    uint32_t non_energized_count;
    // The current quadrant, one of [0, 1, 2, 3]. Each quadrant
    // represents half of a full step.
    int quadrant;
    // Total (forward - backward) full steps (quadrant transitions).
    int full_steps;
    // Total invalid quadrant transitions. Normally 0.
    uint32_t quadrature_errors;
    int capture_size;
};

// Updated by the ADC interrupt routing.
static  IsrStatus isr_status;


// Called from isr
void isr_process_adc_results(int v1, int v2) {
  v1 -= VAL1_OFFSET;
  v2 -= VAL2_OFFSET;

  isr_status.isr_count++;
  isr_status.adc_val1 = v1;
  isr_status.adc_val2 = v2;

  if (isr_status.capture_size < MAX_CAPTURE_SIZE) {
    capture[isr_status.capture_size][0] = v1;
    capture[isr_status.capture_size][1] = v2;
    isr_status.capture_size++;
  }

  // We number the quadrants such that 0, 1, 2, 3, ... is the
  // forward sequence.
  // quadrant 0: [- -]
  // quadrant 1: [+ -]
  // quadrant 2: [+ +]
  // quadrant 3: [- +]
  //  const int new_quadrant = (v1 >= 0)
  //                           ? (v2 >= 0 ? 2 : 1)
  //                           : (v2 >= 0 ? 3 : 0);

  // Quadrants are defined such that full steps are in
  // the middle of their respective quadrant.
  int new_quadrant;
  // Abs(v1) + abs(v2)
  int vtotal = 0;
  if (v1 >= 0) {
    if (v2 >= 0) {
      new_quadrant = v1 > v2 ? 0 : 1;
      vtotal = v1 + v2;
    } else {
      new_quadrant = v1 > -v2 ? 0 : 3;
      vtotal = v1 + -v2;
    }
  } else {
    if (v2 >= 0) {
      new_quadrant = -v1 > v2 ? 2 : 1;
      vtotal = -v1 + v2;
    } else {
      new_quadrant = v1 > v2 ? 3 : 2;
      vtotal = -v1 + -v2;
    }
  }

  // Is the stepper motor energized? (with histeresis).
  const bool old_is_energized = isr_status.is_energized;
  const bool new_is_energized = (vtotal > (old_is_energized ? NON_ENERGIZED1 : NON_ENERGIZED2));
  //digitalWriteFast(LED1, new_is_energized);
  isr_status.is_energized = new_is_energized;

  // Handle the case of an unenergized motor. In unenergized state,
  // the quadrant value reading is meaningless.
  if (!new_is_energized) {
    // Energized to non energized transition. Count it.
    if (old_is_energized) {
      isr_status.non_energized_count++;
    }
  } else {
    // Handle the case of an energized motor.
    // Process quadrant changes.
    const int old_quadrant = isr_status.quadrant;
    if (new_quadrant != old_quadrant) {
      if (!isr_status.is_energized) {
        // If just becomes energized, we don't track quadrant changes and just
        // set below the current quadrant to the new one.
      }
      else if (new_quadrant == ((old_quadrant + 1) & 0x03)) {
        // Forward
        isr_status.full_steps++;
      } else if (new_quadrant == ((old_quadrant - 1) & 0x03)) {
        // Backward
        isr_status.full_steps--;
      } else {
        // Invalid quadrant transition.
        isr_status.quadrature_errors++;
      }
      isr_status.quadrant = new_quadrant;
    }
  }
}

// This ISR routine is invoked at samppling rate. It reads the two ADC
// channels, start the conversion for next cycle and calls isr_process_adc_results() 
// to process the values read.
void adcTimingIsr() {
  // For debugging
  digitalWriteFast(LED3, true);

  // Read ADC1, ADC2 values from previous cycle.
  int result1;
  if (ADC1_HS & ADC_HS_COCO0) {
    result1 = ADC1_R0;
  } else {
    result1 = 1000;
  }

  int result2;
  if (ADC2_HS & ADC_HS_COCO0) {
      result2 = ADC2_R0;
  } else {
    // Should never get here.
    result2 = 0;
  }

  // Start ADC1, ADC2 for next cycle
  ADC2_HC0 = adc2_pin_channel;
  ADC1_HC0 = adc1_pin_channel;

  // Process results from previous cycle.
  isr_process_adc_results(result1, result2);
   
  // For debugging  
  digitalWriteFast(LED3, false);
}

void setup() {
  // Serial
  Serial.begin(9600);

  // Leds
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);

  digitalWriteFast(LED1, 0);
  digitalWriteFast(LED2, 0);
  digitalWriteFast(LED3, 0);

  // Buttons
  pinMode(PUSH_BUTTON1, INPUT_PULLUP);
  pinMode(PUSH_BUTTON2, INPUT_PULLUP);

  // --- Display
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK);
  tft.setTextWrap(false);
  
  // --- ADC
  pinMode(adc1_pin, INPUT);
  pinMode(adc2_pin, INPUT);
  analogReadRes(12);       // reading 12 bits
  analogReadAveraging(1);  // TODO: consider to increase to 4

  //--- timer
  //
  // TDOO: why setting PWM for pin TIMER1_B_PIN, the real output, doesn't work?
  pinMode(TIMER1_B_PIN, OUTPUT);        // Timer output - pin 7.
  Timer1.initialize(20);                // 20 us = 50 kHz
  Timer1.pwm(TIMER1_A_PIN, 1024/4);     // 25% (abitrary)
  Timer1.attachInterrupt(adcTimingIsr); // ISR
}




void loop() {
  //for(;;) {
  //  digitalWriteFast(LED1, !digitalReadFast(LED1));
  //}

 // Serial.println(adc1_pin);
  
  const unsigned long period_ms = 100;
  static unsigned long last_millis = millis();
  unsigned long ms_left = period_ms - (millis() - last_millis);
  if (ms_left > period_ms) { ms_left = period_ms; }  // in case of unsigned underflow
  delay(ms_left);
  last_millis += period_ms;
  
  // Reset
  if (push_button1.update() && push_button1.fallingEdge()) {
    Serial.println("Reset");
    __disable_irq();
    {
      isr_status.non_energized_count = 0;
      isr_status.full_steps = 0;
      isr_status.quadrature_errors = 0;
      isr_status.capture_size = 0;
    }
    __enable_irq();
  }

  // Take a snapshot of isr values and reset isr_count
  IsrStatus _isr_status;
  __disable_irq();
  {
    _isr_status = isr_status;
    isr_status.isr_count = 0;
  }
  __enable_irq();


  static char buffer[200];
  tft.setTextColor(ST7735_WHITE, ST7735_BLACK);

  const int x0 = 25;
  const int dy = 20;
  int y = 20;
  
  tft.setCursor(x0, y);
  sprintf(buffer, "A      %6.2f",  _isr_status.adc_val1  / COUNTS_PER_AMP);
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "B      %6.2f",  _isr_status.adc_val2  / COUNTS_PER_AMP);
  tft.print(buffer);
  y += dy;


  tft.setCursor(x0, y);
  sprintf(buffer, "ERRORS %6lu",  _isr_status.quadrature_errors);
  tft.print(buffer);
  y += dy;

  tft.setCursor(x0, y);
  sprintf(buffer, "POWER     %s",  _isr_status.is_energized? " ON" : "OFF");
  tft.print(buffer);
  y += dy;
  
  tft.setCursor(x0, y);
  sprintf(buffer, "IDLES  %6lu",  _isr_status.non_energized_count);
  tft.print(buffer);
  y += dy;

  tft.setTextColor(ST7735_YELLOW, ST7735_BLACK);

  y += dy;
  tft.setCursor(x0, y);
  sprintf(buffer, "STEPS  %6d",  _isr_status.full_steps);
  tft.print(buffer);


//  if (1) {
//    sprintf(buffer, "[%lu][%d][e:%lu] [%5d, %5d] [e:%d %lu] s:%d  steps:%d ",
//            _isr_status.isr_count, 
//            _isr_status.capture_size,
//            _isr_status.quadrature_errors,
//            _isr_status.adc_val1, _isr_status.adc_val2, _isr_status.is_energized, _isr_status.non_energized_count,
//            _isr_status.quadrant,  _isr_status.full_steps);
//  } else {
//    sprintf(buffer, "%d ", _isr_status.full_steps);
//  }
//  Serial.println(buffer);

  // Print capture buffer
  if (1) { 
    static boolean last_capture_full = false;
    boolean new_capture_full = (_isr_status.capture_size == MAX_CAPTURE_SIZE);
  
    if (new_capture_full && !last_capture_full) {
      // Marker
      //Serial.println("-1000 -1000");
      //Serial.println("0 0");
      for (int i = 0; i < isr_status.capture_size; i++) {
        Serial.print(capture[i][0] / COUNTS_PER_AMP);
        Serial.print(" ");
        Serial.println(capture[i][1] / COUNTS_PER_AMP );
        delay(1);
      }
    }
    last_capture_full = new_capture_full;
  }
}

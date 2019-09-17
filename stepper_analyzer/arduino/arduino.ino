// Skeleton program for reading two input analog channels.
// Tested on Teensy 3.2, 96MHZ (overclocked)

#include <stdio.h>
#include <ADC.h>

// ADC count for i=0 (1.5v of 3.3V full scale)
const uint16_t VAL1_OFFSET = 1902;
const uint16_t VAL2_OFFSET = 1860;

const int adcPin1 = A9;
const int adcPin2 = A3;

ADC *adc = new ADC();

elapsedMicros time;

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  pinMode(adcPin1, INPUT);
  pinMode(adcPin2, INPUT);

  adc->setReference(ADC_REFERENCE::REF_3V3, ADC_0);
  adc->setReference(ADC_REFERENCE::REF_3V3, ADC_1);

  adc->setAveraging(8, ADC_0);
  adc->setAveraging(8, ADC_1);

  adc->setResolution(12, ADC_0);
  adc->setResolution(12, ADC_1);

  adc->setConversionSpeed(ADC_CONVERSION_SPEED::MED_SPEED, ADC_0);
  adc->setConversionSpeed(ADC_CONVERSION_SPEED::MED_SPEED, ADC_1);

  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::MED_SPEED, ADC_0);
  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::MED_SPEED, ADC_1);

  // We use adc0_isr to read also adc1.
  adc->enableInterrupts(ADC_0);

  // NOTE: this return a error status if pins are not supported.
  adc->startSynchronizedContinuous(adcPin1, adcPin2);
  delay(100);
}

struct IsrStatus {
  public:
    IsrStatus() :
      isr_count(0), adc_val1(0), adc_val2(0),
      quadrant(0), quadrants(0),
      quadrature_errors(0) {}
    // Number of isr invocactions so far. Overlofw is normal.
    uint32_t isr_count;
    // Signed adc current readings. For a 200mv/A current sensor, units
    // are (0.2V * 4095)/3.3V = 248 counts/A.
    int  adc_val1;
    int  adc_val2;
    // The current quadrant, one of [0, 1, 2, 3]. Each quadrant
    // represents half of a full step.
    int quadrant;
    // Total (forward - backward) quadrant transitions.
    int quadrants;
    // Total invalid quadrant transitions. Normally 0.
    uint32_t quadrature_errors;
};

// Updated by the ADC interrupt routing.
static  IsrStatus isr_status;

void loop() {
  // Take a snapshot of isr values and reset isr_count
  IsrStatus _isr_status;
  __disable_irq();
  {
    _isr_status = isr_status;
  }
  __enable_irq();

  // Print snapshot
  static uint32_t last_isr_count = 0;
  static char buffer[200];
  sprintf(buffer, "[%lu] [%5d, %5d]  s:%d q:%d e:%lu",
          _isr_status.isr_count - last_isr_count,
          _isr_status.adc_val1, _isr_status.adc_val2,
          _isr_status.quadrant, _isr_status.quadrants,
          _isr_status.quadrature_errors);
  //  sprintf(buffer, "%5d %5d %d %d %lu",
  //          _isr_status.adc_val1, _isr_status.adc_val2,
  //          _isr_status.quadrant*1000, _isr_status.quadrants*1000,
  //          _isr_status.quadrature_errors*1000);
  Serial.println(buffer);
  last_isr_count = _isr_status.isr_count;

  adc->printError();  // Print adc errors, if any
  digitalWriteFast(LED_BUILTIN, !digitalReadFast(LED_BUILTIN));
  delay(100);
}

void adc0_isr(void) {
  static ADC::Sync_result result;

  // Get the latest values of the two channels respectivly.
  // The casting to uint1_t is required only with 16 bit conversion
  // to make sure the MSB bit is not signed extended to the 32bit ints.
  result = adc->readSynchronizedContinuous();
  const int adc_val1 = ((int)((uint16_t)result.result_adc0)) - VAL1_OFFSET;
  const int adc_val2 = ((int)((uint16_t)result.result_adc1)) - VAL2_OFFSET;

  isr_status.isr_count++;
  isr_status.adc_val1 = adc_val1;
  isr_status.adc_val2 = adc_val2;

  // We number the quadrants such that 0, 1, 2, 3, ... is the
  // forward sequence.
  const int new_quadrant = (adc_val1 >= 0)
                        ? (adc_val2 >= 0 ? 2 : 1)
                        : (adc_val2 >= 0 ? 3 : 0);

  // Process quadrant changes.
  const int current_quadrant = isr_status.quadrant;
  if (new_quadrant != current_quadrant) {
    if (isr_status.isr_count == 1) {
      // If first isr call, just update the quadrant below to avoid
      // an invalid transition.
    }
    else if (new_quadrant == ((current_quadrant + 1) & 0x03)) {
      // Forward
      isr_status.quadrants++;
    } else if (new_quadrant == ((current_quadrant - 1) & 0x03)) {
      // Backward
      isr_status.quadrants--;
    } else {
      // Invalid transition
      isr_status.quadrature_errors++;
    }
    isr_status.quadrant = new_quadrant;
  }
}

// Skeleton program for reading two input analog channels.
// Tested on Teensy 3.2, 96MHZ (overclocked)

#include <stdio.h>
#include <ADC.h>
#include <Bounce.h>
#include <FrequencyTimer2.h>


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

static ST7735_t3 tft(TFT_CS, TFT_DC, TFT_MOSI, TFT_SCLK, TFT_RST);

static const int adcPin1 = A9;
static const int adcPin2 = A3;

static const int LED1 = 1;
static const int LED2 = 2;
static const int LED3 = 3;

static const int PUSH_BUTTON1 = 18;
static const int PUSH_BUTTON2 = 19;

static Bounce push_button1 = Bounce(PUSH_BUTTON1, 10);  // 10 ms debounce
static Bounce push_button2 = Bounce(PUSH_BUTTON2, 10);  // 10 ms debounce

// Make it non heap. @@@@@ TODO
//ADC *adc = new ADC();
static ADC adc;

//elapsedMicros time;


void adcTimingIsr() {
    digitalWriteFast(LED3, true);

  // Use static so we don't need to construct each time.
  static ADC::Sync_result result;

  result = adc.readSynchronizedSingle();

  //timer_isr_count++;
  adc.startSynchronizedSingleRead(adcPin1, adcPin2);

  isr_process_adc_result(result);
  
  digitalWriteFast(LED3, false);
}

void setup() {
  
  Serial.begin(9600);

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);

  digitalWriteFast(LED1, 0);
  digitalWriteFast(LED2, 0);
  digitalWriteFast(LED3, 0);

  //adc_timing_timer(adc_timing_isr, 40);



  pinMode(PUSH_BUTTON1, INPUT_PULLUP);
  pinMode(PUSH_BUTTON2, INPUT_PULLUP);

  // --- Display
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK);
  tft.setTextWrap(false);
  
  // --- ADC

  pinMode(adcPin1, INPUT);
  pinMode(adcPin2, INPUT);

  adc.setReference(ADC_REFERENCE::REF_3V3, ADC_0);
  adc.setReference(ADC_REFERENCE::REF_3V3, ADC_1);

  adc.setAveraging(4, ADC_0);
  adc.setAveraging(4, ADC_1);

  adc.setResolution(12, ADC_0);
  adc.setResolution(12, ADC_1);

  adc.setConversionSpeed(ADC_CONVERSION_SPEED::HIGH_SPEED, ADC_0);
  adc.setConversionSpeed(ADC_CONVERSION_SPEED::HIGH_SPEED, ADC_1);

  adc.setSamplingSpeed(ADC_SAMPLING_SPEED::HIGH_SPEED, ADC_0);
  adc.setSamplingSpeed(ADC_SAMPLING_SPEED::HIGH_SPEED, ADC_1);

  // NOTE: this return a error status if pins are not supported.
  adc.startSynchronizedSingleRead(adcPin1, adcPin2);
  // Make sure the first timer ISR will find an adc result. 4 millis
  // is an overkill
  delay(4);

  // FREQUENCYTIMER2_PIN = 5 on Teensy 3.2. Do not use for anything else.
  pinMode(FREQUENCYTIMER2_PIN, OUTPUT);
  FrequencyTimer2::setPeriod(20);  // 20usec -> 50k samplings/sec.
  FrequencyTimer2::setOnOverflow(adcTimingIsr);
  FrequencyTimer2::enable();
}

const int MAX_CAPTURE_SIZE = 5000;
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


void loop() {

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


  if (1) {
    sprintf(buffer, "[%lu][%d][e:%lu] [%5d, %5d] [e:%d %lu] s:%d  steps:%d ",
            _isr_status.isr_count, 
            _isr_status.capture_size,
            _isr_status.quadrature_errors,
            _isr_status.adc_val1, _isr_status.adc_val2, _isr_status.is_energized, _isr_status.non_energized_count,
            _isr_status.quadrant,  _isr_status.full_steps);
  } else {
    sprintf(buffer, "%d ", _isr_status.full_steps);
  }
  Serial.println(buffer);

  // Print capture
//  if (1) { 
//    static boolean last_capture_full = false;
//    boolean new_capture_full = (_isr_status.capture_size == MAX_CAPTURE_SIZE);
//  
//    if (new_capture_full && !last_capture_full) {
//      // Marker
//      Serial.println("-1000 -1000");
//      Serial.println("0 0");
//      for (int i = 0; i < isr_status.capture_size; i++) {
//        Serial.print(capture[i][0]);
//        Serial.print(" ");
//        Serial.println(capture[i][1]);
//      }
//    }
//    last_capture_full = new_capture_full;
//  }

  adc.printError();  // Print adc errors, if any
}

//adc0_isr;

// Called from isr
void isr_process_adc_result(ADC::Sync_result& result) {

  // The casting to uint1_t is required only with 16 bit conversion
  // to make sure the MSB bit is not signed extended to the 32bit ints.
  const int v1 = ((int)((uint16_t)result.result_adc0)) - VAL1_OFFSET;
  const int v2 = ((int)((uint16_t)result.result_adc1)) - VAL2_OFFSET;

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

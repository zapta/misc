// Skeleton program for reading two input analog channels.
// Tested on Teensy 3.2, 96MHZ (overclocked)

#include <string.h>
#include <stdio.h>

#include <Bounce.h>
#include<TimerOne.h>
#include <ST7735_t3.h>

// Display is 1.8", portrait, 128 x 160.
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
// TODO: define a macro and declare in milliamps units.
const uint32_t NON_ENERGIZED1 = 50;
const uint32_t NON_ENERGIZED2 = 150;

//Hysteresis for quadrant boundaries.
const int QUADRANT_HYSTERESIS_MILLIAMPS = 100;
// TODO: define and use a macro to convert milliamps to adc counts.
const int QUADRANT_HYSTERESIS_COUNTS = (QUADRANT_HYSTERESIS_MILLIAMPS * COUNTS_PER_AMP) / 1000;

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

enum Direction {
  UNKNOWN_DIRECTION,
  FORWARD,
  BACKWARD
};

const int NUM_BUCKETS = 20;

// A single histogram bucket
struct HistogramBucket {
  uint32_t total_ticks_in_steps;       // total adc samples in steps in this bucket;
  uint64_t total_step_peak_currents;   // total max step current in ADC counts
  uint32_t total_steps;                // total steps
};

struct IsrStatus {
  public:
    IsrStatus() :
      isr_count(0), adc_val1(0), adc_val2(0),
      is_energized(false), non_energized_count(0), quadrant(0), 
      full_steps(0), quadrature_errors(0), capture_size(0), 
      last_step_direction(UNKNOWN_DIRECTION), max_current_in_step(0), ticks_in_step(0) {
      memset(buckets, 0, sizeof(buckets)); 
    }
    
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
    // for tracking step speed
    Direction last_step_direction;
    // AdC counts, single coil.
    uint32_t max_current_in_step; // max current in current step, in ADC count units. Dominate coild.
    uint32_t ticks_in_step; // ticks in current step.
    // Histogram, each bucket represents a range of steps/sec speeds.
    HistogramBucket buckets[NUM_BUCKETS];
};

// Updated by the ADC interrupt routing.
static  IsrStatus isr_status;


// Called from isr.
inline void isr_add_step_to_histogram(int quadrant, Direction entry_direction, Direction exit_direction, uint32_t ticks, uint32_t max_current_in_step) {
  // Ignoring this step if not entering and exiting this step in same forward or backward direction.
  if (entry_direction != exit_direction || entry_direction == UNKNOWN_DIRECTION) {
    return;
  }

  // @@@ temporary
 // if (quadrant != 0) {
 //   return;
 // }

  uint32_t speed = 50000 / ticks;  // speed in steps per second


  
  if (speed < 50) {
    return;   // ignore very slow steps as they dominate the histogram.
  }

  uint32_t bucket_index = speed / 100;   // Each bucket represents a speed range of 100 steps/sec.
  if (bucket_index >= NUM_BUCKETS) {
    bucket_index =  NUM_BUCKETS - 1;
  }

  HistogramBucket& bucket = isr_status.buckets[bucket_index];
  bucket.total_ticks_in_steps += ticks;
  bucket.total_step_peak_currents += max_current_in_step;
  bucket.total_steps++;
}

// Called from isr
inline void isr_process_adc_results(int v1, int v2) {
  // Apply offsets to be zero relative.
  v1 -= VAL1_OFFSET;
  v2 -= VAL2_OFFSET;

  // Update isr status with latest readings.
  isr_status.isr_count++;
  isr_status.adc_val1 = v1;
  isr_status.adc_val2 = v2;

  // Append readings to capture buffer if needed.
  if (isr_status.capture_size < MAX_CAPTURE_SIZE) {
    capture[isr_status.capture_size][0] = v1;
    capture[isr_status.capture_size][1] = v2;
    isr_status.capture_size++;
  }

  // Determine if motor is energied. Use hysteresis to reject noise
  const bool old_is_energized = isr_status.is_energized;
  const uint32_t total_current = abs(v1) + abs(v2);
  const bool new_is_energized = (total_current > (old_is_energized ? NON_ENERGIZED1 : NON_ENERGIZED2));
  isr_status.is_energized = new_is_energized;
  //sprintf(isr_debug, "%d, %d, %d", old_is_energized, total_current, new_is_energized);

  // Handle the case of non energized. No need to go through quandrant decoding.
  
  if (!new_is_energized) {
    if (old_is_energized) {
      // Becoming non energized.
      isr_status.last_step_direction = UNKNOWN_DIRECTION;
      isr_status.ticks_in_step = 0;
      isr_status.non_energized_count++;
    } else {
      // Staying non energized
    }
    return;
  }
    
  // Here when energizeed. Decode quadrant.
  //
  // Quadrants are defined such that full steps are in
  // the middle of their respective quadrant.
  const int old_quadrant = isr_status.quadrant;
  // Introduce hystersis in the comparison of |v1| > |v2| which determines 
  // quadrants boundaries. This is to reject noise and avoid bouncing around
  // quadrant boundaries. The hysterestis is controlled by the previous quadrant.
  const int v1_hysteresis = (old_quadrant & 0x01) 
      ? -QUADRANT_HYSTERESIS_COUNTS / 2  // odd quadrant, dominated by |v1| <= |v2|
      : QUADRANT_HYSTERESIS_COUNTS / 2;  // even quadrant, dominated by |v1| > |v2|
  int new_quadrant; // set below to [0, 3]
  uint32_t max_current;  // max coil current
  //int vtotal;  // set below to |v1| + |v2|
  if (v1 >= 0) {
    if (v2 >= 0) {
      // v1 >= 0, v2 >= 0
      if ((v1 + v1_hysteresis) > v2) {
        new_quadrant = 0;
        max_current = v1;
      } else {
        new_quadrant = 1;
        max_current = v2;
      }
      //vtotal = v1 + v2;
    } else {
      // v1 >= 0, v2 < 0
      if ((v1 + v1_hysteresis) > -v2) {
        new_quadrant = 0;
        max_current = v1;
      } else {
        new_quadrant = 3;
        max_current = -v2;
      }
      //vtotal = v1 + -v2;
    }
  } else {
    if (v2 >= 0) {
      // v1 < 0, v2 >= 0
      if ((-v1 + v1_hysteresis) > v2) {
         new_quadrant = 2;
         max_current = -v1;
      } else {
         new_quadrant = 1;
         max_current = v2;
      }
      //vtotal = -v1 + v2;
    } else {
      // v1 < 0, v2 < 0
      if ((-v1 + v1_hysteresis) > -v2) {
        new_quadrant = 2;
        max_current = -v1;
      } else {
        new_quadrant = 3;
        max_current = -v2;
      }
      //vtotal = -v1 + -v2;
    }
  }
  isr_status.quadrant = new_quadrant;


//  // Is the stepper motor energized? (with histeresis).
//  const bool old_is_energized = isr_status.is_energized;
//  const bool new_is_energized = (max_current > (old_is_energized ? NON_ENERGIZED1 : NON_ENERGIZED2));
//  sprintf(isr_debug, "%d, %lu, %d", old_is_energized, max_current, new_is_energized);
//  isr_status.is_energized = new_is_energized;

//  // Track steps
//  if (!new_is_energized && !old_is_energized) {
//    // Case 1: motor stays non energized
//    // nothing to do
//  } else if (!new_is_energized && old_is_energized) {
//    // Case 2: motor became non energized
//    isr_status.last_step_direction = UNKNOWN_DIRECTION;
//    isr_status.ticks_in_step = 0;
//    isr_status.non_energized_count++;
//  } else 
//  
  if (!old_is_energized) {
    // Case 1: motor became energized.
    isr_status.last_step_direction = UNKNOWN_DIRECTION;
    isr_status.ticks_in_step = 1;
    isr_status.max_current_in_step = max_current;
  } else if (new_quadrant == old_quadrant) {
    // Case 2: staying in same quadrant
    isr_status.ticks_in_step++;
    if (max_current > isr_status.max_current_in_step) {
      isr_status.max_current_in_step = max_current;
    }
  } else if (new_quadrant == ((old_quadrant + 1) & 0x03)) {
    // Case 3: Forward step
    isr_status.full_steps++;
    isr_add_step_to_histogram(old_quadrant, isr_status.last_step_direction, FORWARD, isr_status.ticks_in_step, isr_status.max_current_in_step);
    isr_status.last_step_direction = FORWARD;
    isr_status.ticks_in_step = 1;
    isr_status.max_current_in_step = max_current;
  } else if (new_quadrant == ((old_quadrant - 1) & 0x03)) {
    // Case 4: backward step
    isr_status.full_steps--;
    isr_add_step_to_histogram(old_quadrant, isr_status.last_step_direction, BACKWARD, isr_status.ticks_in_step, isr_status.max_current_in_step);
    isr_status.last_step_direction = BACKWARD;
    isr_status.ticks_in_step = 1;
    isr_status.max_current_in_step = max_current;
  } else {
    // Case 5: Invalid quadrant transition.
    isr_status.quadrature_errors++;
    isr_status.last_step_direction = UNKNOWN_DIRECTION;
    isr_status.ticks_in_step = 1;
    isr_status.max_current_in_step = max_current;
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

void draw_histogram(uint64_t buffer[NUM_BUCKETS]) {
    // Determine full scale value
    uint64_t full_scale = 1;
    for (int i = 0; i < NUM_BUCKETS; i++) {
      if (buffer[i] > full_scale) {
        full_scale = buffer[i];
      }
    }

    // Draw 
    for (int i = 0; i < NUM_BUCKETS; i++) {
      const uint64_t value = buffer[i];
      // TODO: change the bar length calculation to round fraction of pixels up.
      int bar_length = (100 * value) / full_scale;
      if (value > 0 && bar_length < 1) {
        bar_length = 1;
      }

      // Buckets are drawen buttom up on the screen.
      const int x0 =  10;
      const int y = 3 + (NUM_BUCKETS - i) * 7;
      // First x, y is 0,0 (upper left corner).
      if (bar_length > 0) {
        tft.fillRect(x0, y , bar_length, 6, ST7735_YELLOW);
        tft.fillRect(x0 + bar_length, y , 100 - bar_length, 6, ST7735_BLACK);
      } else {
        // Bar of length 1 in a neutral color
        tft.fillRect(x0, y , 1, 6, ST7735_BLUE);  // TODO: make gray
        tft.fillRect(x0 + 1, y , 100 - 1, 6, ST7735_BLACK);  
      }
    }  
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
  //Timer1.initialize(200);                // 20 us = 50 kHz
  Timer1.pwm(TIMER1_A_PIN, 1024/4);     // 25% (abitrary)
  Timer1.attachInterrupt(adcTimingIsr); // ISR
}




void loop() {
  //Serial.println(isr_debug);
  //for(;;) {
  //  digitalWriteFast(LED1, !digitalReadFast(LED1));
  //}

 // Serial.println(adc1_pin);
  
  const unsigned long period_ms = 500;
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
      memset(isr_status.buckets, 0, sizeof(isr_status.buckets)); 
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

  //Serial.println(_isr_status.isr_debug);


  static char buffer[200]; // for text
  static uint64_t histogram_buffer[NUM_BUCKETS];  // for histogram drawing


  if (0) {
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
  } else if (0) {
    // copy values to buffer
    for (int i = 0; i < NUM_BUCKETS; i++) {
      histogram_buffer[i] = _isr_status.buckets[i].total_ticks_in_steps;
    }
    draw_histogram(histogram_buffer);
    
//    // Determine ticks for full scale.
//    uint64_t full_scale_ticks = 10;
//    for (int i = 0; i < NUM_BUCKETS; i++) {
//      const uint64_t ticks_in_bucket = _isr_status.buckets[i].total_ticks_in_steps;
//      if (ticks_in_bucket > full_scale_ticks) {
//        full_scale_ticks = ticks_in_bucket;
//      }
//    }
//    
//    for (int i = 0; i < NUM_BUCKETS; i++) {
//      const uint64_t ticks_in_bucket = _isr_status.buckets[i].total_ticks_in_steps;
//      // TODO: change the bar length calculation to round fraction of pixels up.
//      int bar_length = (100 * ticks_in_bucket) / full_scale_ticks;
//      if (ticks_in_bucket > 0 && bar_length < 1) {
//        bar_length = 1;
//      }
//
//      // Buckets are from slow to fast so drawing bottom to top.
//      const int x0 =  10;
//      const int y = 3 + (NUM_BUCKETS - i) * 7;
//      // First x, y is 0,0 (upper left corner).
//      if (bar_length > 0) {
//        tft.fillRect(x0, y , bar_length, 6, ST7735_YELLOW);
//        tft.fillRect(x0 + bar_length, y , 100 - bar_length, 6, ST7735_BLACK);
//      } else {
//        // Bar of length 1 in a neutral color
//        tft.fillRect(x0, y , 1, 6, ST7735_BLUE);  // TODO: make gray
//        tft.fillRect(x0 + 1, y , 100 - 1, 6, ST7735_BLACK);  
//      }
//    }
  } else {
    // copy values to buffer
    for (int i = 0; i < NUM_BUCKETS; i++) {
      const HistogramBucket& bucket = _isr_status.buckets[i];
      if (bucket.total_steps == 0) {
        histogram_buffer[i] = 0;
      } else {
        // current in millis
        histogram_buffer[i] = (1000 * bucket.total_step_peak_currents / bucket.total_steps) / COUNTS_PER_AMP;
      }
    }
    draw_histogram(histogram_buffer);
  }

//   uint32_t total_ticks_in_steps;       // total adc samples in steps in this bucket;
//  uint64_t total_step_peak_currents;   // total max step current in ADC counts
//  uint32_t total_steps;                // total step
     

  if (1) {
    sprintf(buffer, "[%lu][%d][er:%lu] [%5d, %5d] [en:%d %lu] s:%d/%d  steps:%d",
            _isr_status.isr_count, 
            _isr_status.capture_size,
            _isr_status.quadrature_errors,
            _isr_status.adc_val1, _isr_status.adc_val2, _isr_status.is_energized, _isr_status.non_energized_count,
            _isr_status.quadrant, _isr_status.last_step_direction,  _isr_status.full_steps);
    Serial.println(buffer);
  } else {
    sprintf(buffer, "%d ", _isr_status.full_steps);
    Serial.println(buffer);
  }
  //Serial.println(buffer);
  
  for (int i = 0; i < NUM_BUCKETS; i++) {
    Serial.print(_isr_status.buckets[i].total_ticks_in_steps);
    Serial.print(" ");
  }
  Serial.println();
  
    for (int i = 0; i < NUM_BUCKETS; i++) {
      if (!_isr_status.buckets[i].total_steps) {
        Serial.print(0);
      } else {
        Serial.print((uint32_t)(_isr_status.buckets[i].total_step_peak_currents / _isr_status.buckets[i].total_steps));
      }
    Serial.print(" ");
  }
  Serial.println();

  // Print capture buffer
  if (0) { 
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

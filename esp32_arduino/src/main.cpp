#include <Arduino.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <esp_log.h>

#include "acquisition/adc_task.h"
#include "acquisition/analyzer.h"
#include "settings/nvs_config.h"
#include "io/io.h"
#include "misc/util.h"
#include "settings/controls.h"
#include "misc/elapsed.h"

static constexpr auto TAG = "main";

static const analyzer::Settings kDefaultSettings = {
    .offset1 = 1800, .offset2 = 1800, .is_reverse_direction = false};

static analyzer::State state;
static analyzer::AdcCaptureBuffer capture_buffer;

// Used to blink N times LED 2.
static Elapsed led2_timer;
// Down counter. If value > 0, then led2 blinks and bit 0 controls
// the led state.
static uint16_t led2_counter;

// static Elapsed periodic_timer;

// Used to generate blink to indicates that
// acquisition is working.
static uint32_t analyzer_counter = 0;

static void start_led2_blinks(uint16_t n, uint32_t millis_now) {
  led2_timer.reset(millis_now);
  led2_counter = n * 2;
  io::LED2.write(led2_counter > 0);
}


BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t value = 0;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) { deviceConnected = true; };

  void onDisconnect(BLEServer* pServer) { deviceConnected = false; }
};

void setup() {
  Serial.begin(115200);  // open the serial port at 9600 bps:
  Serial.println();

  // delay(1000);  // Setting time.

  io::LED1.clear();
  io::LED2.clear();

  // --------- ADC

// Init config.
  // nvs_config::setup();
  util::nvs_init();

  // Fetch settings.
  analyzer::Settings settings;
  if (!nvs_config::read_acquisition_settings(&settings)) {
    ESP_LOGE(TAG, "Failed to read settings, will use default.");
    settings = kDefaultSettings;
  }
  ESP_LOGI(TAG, "Settings: %d, %d, %d", settings.offset1, settings.offset2,
           settings.is_reverse_direction);

  // Init acquisition.
  analyzer::setup(settings);
  adc_task::setup();

  // --------- BLE

  // Create the BLE Device
  BLEDevice::init("ESP32");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService* pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                               BLECharacteristic::PROPERTY_WRITE |
                               BLECharacteristic::PROPERTY_NOTIFY |
                               BLECharacteristic::PROPERTY_INDICATE);

  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(
      0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  ESP_LOGI(TAG, "Waiting a client connection to notify...");

  // Serial.println("Waiting a client connection to notify...");
}

void loop() {
  const uint32_t millis_now = millis();

  // Handle button
  // const Button::ButtonEvent button_event = io::BUTTON1.update(millis_now);
  // if (button_event != Button::EVENT_NONE) {
  //   ESP_LOGI(TAG, "Button event: %d", button_event);
  //   log_i("Button event: %d", button_event);
  //   printf("xxx\n");
  //   Serial.println("yyy");
  // }
  // io::LED1.write(io::BUTTON1.is_pressed());

    // Handle button.
  const Button::ButtonEvent button_event = io::BUTTON1.update(millis_now);
  if (button_event != Button::EVENT_NONE) {
    ESP_LOGI(TAG, "Button event: %d", button_event);

    // Handle single click. Reverse direction.
    if (button_event == Button::EVENT_SHORT_CLICK) {
      bool new_is_reversed_direcction;
      const bool ok = controls::toggle_direction(&new_is_reversed_direcction);
      const uint16_t num_blinks = !ok ? 10 : new_is_reversed_direcction ? 2 : 1;
      start_led2_blinks(num_blinks, millis_now);
    }

    // Handle long press. Zero calibration.
    else if (button_event == Button::EVENT_LONG_PRESS) {
      // zero_setting = true;
      const bool ok = controls::zero_calibration();
      start_led2_blinks(ok ? 3 : 10, millis_now);
    }
  }


  // Update LED blinks.  Blinking indicates analyzer works
  // and provides states. High speed blink indicates connection
  // status.
  const int blink_shift = deviceConnected ? 0 : 3;
  const bool blink_state = ((analyzer_counter >> blink_shift) & 0x7) == 0x0;
  // Supress LED1 while blinking LED2. We want to have them appart on the
  // board such that they don't interfere visually.
  io::LED1.write(blink_state && !led2_counter);

  if (led2_counter > 0 && led2_timer.elapsed_millis(millis_now) >= 500) {
    led2_timer.reset(millis_now);
    led2_counter--;
    io::LED2.write(led2_counter > 0 && !(led2_counter & 0x1));
  }


  // Blocking. 50Hz.
  analyzer::pop_next_state(&state);

  analyzer_counter++;

  // if ((loop_counter & 0x0f) == 0) {
  //   io::LED1.toggle();
  // }

  // Dump state
  if (analyzer_counter % 100 == 0) {
    analyzer::dump_state(state);
    adc_task::dump_stats();
  }


  // ESP_LOGI("TAG", "aaa");
  // Serial.print("bbb\n");
  //  delay(1000);
  //  util::dump_tasks();

  // notify changed value
  if (deviceConnected) {
    pCharacteristic->setValue((uint8_t*)&value, 4);
    pCharacteristic->notify();
    value++;
    //delay(20);  // bluetooth stack will go into congestion, if too many packets
    //            // are sent, in 6 hours test i was able to go as low as 3ms
  }
  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    // TODO: Make this a state instead of delay();
    delay(500);  // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println("start advertising");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}
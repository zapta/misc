// Wifi Duet3D monitor for the M5Stack core.

// Expects a SD card with config file named /duet_buddy.json
// and fields like these:
//
// {
//   "wifi_ssid" : "xxx",
//   "wifi_password" : "yyy",
//   "duet_ip" : "10.20.30.40"
// }
//
// The program polls the duet at the url 
// http://xx.xx.xx.xx/rr_status?type=3
// and displayes selected values such as 
// state and progress.

// TODO: code cleanup.
// TODO: add info fields for temps and Z height.
// TODO: add beeping in pause mode.

#include <Arduino.h>
#include "duet_parser.h"
#include "config_parser.h"
#include <M5Stack.h>
#include <stdint.h>
#include <WiFi.h>
#include <FS.h>
#include <SD.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>

// This includes definitions of CONFIG_SSID, CONFIG_PASSWORD and CONFIG_HOST
// literal strings and is not checked in into github.
//#include "_config.h"

// 16 bits RGB565 colors. Picked using
// http://www.barth-dev.de/online/rgb565-color-picker/

static const uint16_t kBlack  = 0x0000;
static const uint16_t kBlue   = 0x001F;
static const uint16_t kRed    = 0xF800;
static const uint16_t kYellow = 0xFFE0;
static const uint16_t kGreen  = 0x07E0;
static const uint16_t kPurple = 0x801F;
static const uint16_t kGray   = 0xC618;

static WiFiMulti wifiMulti;
static HTTPClient http;

static JsonParser json_parser;
static DuetParser duet_parser;
// Stores configuration parsed from SD file.
static ConfigParser config_parser;
static SimpleString<80> duet_url;

// Per duet status char screen configurations.
// Colors are 16 bit RGB565 format.
struct StatusConfig {
  // The status char as returned by dutet. The special
  // char '*' indicates default catch all terminator.
  const char c;
  // User friendly status name.
  const char* text;
  const uint16_t bg_color;
  const uint16_t text_color;
};

static const StatusConfig status_configs[] = {
  {'A', "PAUSED", kPurple, kBlack},
  {'B', "BUSY", kRed, kBlack},
  {'C', "CONFIGURING", kYellow, kBlack},
  {'D', "PAUSING", kYellow, kBlack},
  {'F', "FLASHING", kYellow, kBlack},
  {'I', "IDLE", kGreen, kBlack},
  {'P', "PRINTING", kRed, kBlack},
  {'R', "RESUMING", kYellow, kBlack},
  {'S', "PAUSED", kYellow, kBlack},
  // Default terminator. Must be last.
  {'*', "[unknown]", kGray, kBlack}
};

// Finds the configuration for a given duet status char.
static const StatusConfig& decodeStatusConfig(char c) {
  const StatusConfig* p = status_configs;
  for (;;) {
    // Actual match or a catch all default terminator.
    if (p->c == c || p->c == '*') {
      return *p;
    }
    p++;
  }
}

// Common helper for text screens.
static void initTextScreen(uint16_t bg_color, uint16_t text_color) {
  M5.Lcd.fillScreen(bg_color);
  M5.Lcd.setTextColor(text_color, bg_color);
  M5.Lcd.setTextSize(2);
  M5.Lcd.setCursor(0, 12);
}

static bool fatal_error = false;

// Common rendering for all fatal error messages.
static void drawScreenFatalError(const char* msg) {
  fatal_error = true;
  initTextScreen(kBlue, kYellow);
  M5.Lcd.print(" FATAL ERROR:\n\n ");
  M5.Lcd.print(msg);
}


static void drawScreenNoWifi() {
  initTextScreen(kBlue, kYellow);
  M5.Lcd.print(" Connecting to WIFI....");
}

static void drawScreenNoHttpConnection(const char* error_message) {
 // last_screen = SCREEN_NO_HTTP;
  initTextScreen(kBlue, kYellow);
  M5.Lcd.print(" Duet connection failed:.\n\n ");
  M5.Lcd.println(error_message);
}

static void drawScreenBadResponse() {
  initTextScreen(kBlue, kYellow);
  M5.Lcd.print(" Bad response from duet.");
}

static void drawScreenInfo(const DuetStatus& duet_status) {
  // Map the duet status char to screen configuration.
  const StatusConfig& config = decodeStatusConfig(duet_status.state_char);
  M5.Lcd.fillScreen(config.bg_color);
  M5.Lcd.setTextColor(config.text_color);

  if (duet_status.progress_permils) {
    M5.Lcd.setCursor(180, 3, 2);
    M5.Lcd.setTextSize(3);
    M5.Lcd.printf("%d.%d%%", duet_status.progress_permils / 10, duet_status.progress_permils % 10);
  }

  M5.Lcd.setCursor(20, 80, 2);
  M5.Lcd.setTextSize(4);
  M5.Lcd.print(config.text);
}

void setup() {
  M5.begin();
  Serial.begin(115200);
  Serial.println();

  // Open SD drive.
  if (!SD.begin()) {
    drawScreenFatalError("SD card not found.");
    return;
  }

  // Open config file
  File file = SD.open("/duet_buddy.json");
  if (!file) {
    drawScreenFatalError("Config file not found.");
    return;
  }

  // Parse config file. Results are stored in config_parser.
  Serial.println("Parsing file:");
  json_parser.StartParsing(&config_parser);
  while (file.available()) {
    const char c = file.read();
    Serial.print(c);
    json_parser.ParseNextChar(c);
  }
  Serial.println();
  file.close();

  // Config json parsed ok?
  if (!config_parser.IsParsedMessageOk()) {
    drawScreenFatalError("Bad config file.");
    return;
  }

  // Has all required config values?
  const Config& config = config_parser.ParsedData();
  if (config.wifi_ssid_.isEmpty() || config.wifi_password_.isEmpty() || config.duet_ip_.isEmpty()) {
    drawScreenFatalError("Missing required config field.");
    return;
  }

  // Setup Wifi AP.
  if (!wifiMulti.addAP(config.wifi_ssid_.c_str(), config.wifi_password_.c_str())) {
    drawScreenFatalError("Wifi setup failed.");
    return;
  }

  // Construct duet URL string.
  duet_url.add("http://");
  duet_url.add(config.duet_ip_.c_str());
  duet_url.add("/rr_status?type=3");
  Serial.printf("Duet url: [%s]\n", duet_url.c_str());

  // Initialization done OK. Next we will connect to Wifi within
  // loop().
  drawScreenNoWifi();
}


void loop() {
  // Fatal error. Stay in this screen.
  if (fatal_error) {
    delay(10000);
    return;
  }

  // No wifi connection. Try again.
  if ((wifiMulti.run(10000) != WL_CONNECTED)) {
    drawScreenNoWifi();
    delay(500);
    return;
  }

  // Connect to duet and send a Get status http request.
  //http.begin(url);
  http.begin(duet_url.c_str());
  Serial.print("[HTTP] GET ");
  Serial.println(duet_url.c_str());
  const int httpCode = http.GET();
  Serial.printf("[HTTP] GET... code: %d\n", httpCode);


  // No HTTP connection or an HTTP error status.
  if (httpCode != HTTP_CODE_OK) {
    drawScreenNoHttpConnection(http.errorToString(httpCode).c_str());
    http.end();  // remember to close the http client.
    delay(500);
    return;
  }

  // Got http response. Try parsing the json response
  // We don't load the entire json doc into memory but
  // parse it as a stream for a smaller memory footprint.
  json_parser.StartParsing(&duet_parser);
  WiFiClient& stream = http.getStream();
  while (stream.available()) {
    int c = stream.read();
    json_parser.ParseNextChar(c);
    Serial.print(char(c));
  }

  Serial.println("Done parsing, closing http");
  http.end();

  // Duet Json parsing failed. Not an expected response.
  if (!duet_parser.IsParsedMessageOk()) {
    Serial.println("Message not ok");
    drawScreenBadResponse();
    delay(1000);
    return;
  }

  // All is good and we got a valid json response.
  const DuetStatus& duet_status = duet_parser.ParsedData();
  drawScreenInfo(duet_status);
  delay(3000);
}

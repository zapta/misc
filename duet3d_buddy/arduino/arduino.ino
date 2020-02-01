// Wifi Duet3D monitor for the M5Stack core.

// TODO: cleanup code.
// TODO: read wifi and duet configuraiton from sd card.
// TODO: add info fields for temps and Z height.
// TODO: add beeping in pause mode.

#include <Arduino.h>
#include "duet_parser.h"
#include <M5Stack.h>
#include <stdint.h>
#include <WiFi.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>

// This includes definitions of CONFIG_SSID, CONFIG_PASSWORD and CONFIG_HOST
// literal strings and is not checked in into github.
#include "_config.h"

// 16 bits RGB565 colors. Picked using
// http://www.barth-dev.de/online/rgb565-color-picker/

static const uint16_t kBlack  = 0x0000;
static const uint16_t kBlue   = 0x001F;
static const uint16_t kRed    = 0xF800;
static const uint16_t kYellow = 0xFFE0;
static const uint16_t kGreen  = 0x07E0;
static const uint16_t kPurple = 0x801F;
static const uint16_t kGray   = 0xC618;


// TODO: Read url and wifi info from sd card file.
static const char url[] = "http://"  CONFIG_HOST "/rr_status?type=3";

static WiFiMulti wifiMulti;
static HTTPClient http;
static DuetParser duet_parser;
static DuetStatus duet_status;

static M5Display& Lcd = M5.Lcd;

enum Screen {
  SCREEN_NO_SETUP,
  SCREEN_NO_WIFI,
  SCREEN_WIFI_CONNECTED,
  SCREEN_NO_HTTP,
  SCREEN_BAD_RESPONSE,
  SCREEN_ERROR,
  SCREEN_INFO
};

static Screen last_screen;

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
    if (p->c == '*' || p->c == c) {
      return *p;
    }
    p++;
  }
}

static void initTextScreen(uint16_t bg_color, uint16_t text_color) {
  Lcd.fillScreen(bg_color);
  Lcd.setTextColor(text_color, bg_color);
  Lcd.setTextSize(2);
  Lcd.setCursor(0, 12);
}

static void drawScreenNoSetup() {
  last_screen = SCREEN_NO_SETUP;
  initTextScreen(kBlue, kYellow);
  Lcd.println(" Wifi setting failed.");
}

static void drawScreenNoWifi() {
  last_screen = SCREEN_NO_WIFI;
  initTextScreen(kBlue, kYellow);
  Lcd.print(" No WIFI connection.\n\n Trying...");
}

static void drawScreenWifiConnected() {
  last_screen = SCREEN_WIFI_CONNECTED;
  initTextScreen(kBlue, kYellow);
  Lcd.print(" Wifi connected.\n\n No connection to Duet.\n\n Trying...");
}

static void drawScreenNoHttpConnection(const char* error_message) {
  last_screen = SCREEN_NO_HTTP;
  initTextScreen(kBlue, kYellow);
  Lcd.print(" Connection to Duet failed.\n\n ");
  Lcd.println(error_message);
}

static void drawScreenBadResponse() {
  last_screen = SCREEN_BAD_RESPONSE;
  initTextScreen(kBlue, kYellow);
  Lcd.print(" Bad response from duet.");
}

static void drawScreenInfo(const DuetStatus& duet_status) {
  last_screen = SCREEN_INFO;

  // Map the duet status char to screen configuration.
  const StatusConfig& config = decodeStatusConfig(duet_status.state_char);
  Lcd.fillScreen(config.bg_color);
  Lcd.setTextColor(config.text_color);

  if (duet_status.progress_permils) {
    Lcd.setCursor(180, 3, 2);
    Lcd.setTextSize(3);
    Lcd.printf("%d.%d%%", duet_status.progress_permils / 10, duet_status.progress_permils % 10);
  }

  Lcd.setCursor(20, 80, 2);
  Lcd.setTextSize(4);
  Lcd.print(config.text);
}

void setup() {
  M5.begin();
  Serial.begin(115200);
  Serial.println();
  
  if (wifiMulti.addAP(CONFIG_SSID, CONFIG_PASSWORD)) {
    drawScreenNoWifi();
  } else {
    // This is a fatal error.
    drawScreenNoSetup();
  }

  delay(1000);
}


void loop() {
  // Fatal error. Stay in this screen.
  if (last_screen == SCREEN_NO_SETUP) {
    delay(500);
    return;
  }

  // No wifi connection.
  if ((wifiMulti.run() != WL_CONNECTED)) {
    drawScreenNoWifi();
    delay(500);
    return;
  }

  // Just established wifi connection.
  if (last_screen == SCREEN_NO_WIFI) {
    drawScreenWifiConnected();
    delay(1000);
    return;
  }

  // Connect to duet and send a Get status http request.
  http.begin(url);
  Serial.print("[HTTP] GET...\n");
  const int httpCode = http.GET();
  Serial.printf("[HTTP] GET... code: %d\n", httpCode);


  // No HTTP connection or an HTTP error status.
  if (httpCode != HTTP_CODE_OK) {
    drawScreenNoHttpConnection(http.errorToString(httpCode).c_str());
    http.end();  // remember to close the http client.
    delay(500);
    return;
  }


  // Got http response. Try to parse the json format.
  // We don't load the entire json doc into memory but 
  // parse it as a stream for a smaller memory footprint.
  duet_parser.StartParsingJsonMessage();
  WiFiClient& stream = http.getStream();
  while (stream.available()) {
    int c = stream.read();
    duet_parser.ParseNextChar(c);
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
  duet_status = duet_parser.GetParsedDuetStatus();
  drawScreenInfo(duet_status);
  delay(3000);
}

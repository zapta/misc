// Wifi Duet3D monitor for the M5Stack core.

// TODO: cleanup code.

#include <Arduino.h>
#include "duet_parser.h"
#include <M5Stack.h>

#include <WiFi.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>

// This includes definitions of CONFIG_SSID, CONFIG_PASSWORD and CONFIG_HOST
// literal strings and is not checked in into github.
#include "_config.h"

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

struct StatusChar {
  const char c;
  const char* text;
  const int color;
};

static const StatusChar status_chars[] = {
  {'A', "Paused", 0x123},
  {'B', "Busy", 0x123},
  {'C', "Configuring", 0x123},
  {'D', "Pausing", 0x123},
  {'F', "Flashing", 0x123},
  {'I', "Idle", 0x123},
  {'P', "Printing", 0x123},
  {'R', "Resuming", 0x123},
  {'S', "Stopped", 0x123},
  {'*', "[unknown]", 0x123}  // catch all terminator
};

static const StatusChar* decodeStatusChar(char c) {
  const StatusChar* p = status_chars;
  for (;;) {
    if (p->c == '*' || p->c == c) {
      return p;
    }
    p++;
  }
}

static void drawScreenNoSetup() {
  last_screen = SCREEN_NO_SETUP;
  Lcd.fillScreen(0x001F);
  Lcd.setTextSize(2);

  Lcd.setCursor(0, 0);
  Lcd.println("Wifi setting failed.");
}

static void drawScreenNoWifi() {
  last_screen = SCREEN_NO_WIFI;
  Lcd.fillScreen(0x001F);
  Lcd.setTextSize(2);
  Lcd.setCursor(0, 0);
  Lcd.println("Trying to connect to Wifi");
  Lcd.println("access point.");
}

static void drawScreenWifiConnected() {
  last_screen = SCREEN_WIFI_CONNECTED;
  Lcd.fillScreen(0x001F);
  Lcd.setTextSize(2);
  Lcd.setCursor(0, 0);
  Lcd.println("Wifi connected.");
  Lcd.println("Trying to connect to Duet.");
}

static void drawScreenNoHttpConnection(const char* error_message) {
  last_screen = SCREEN_NO_HTTP;
  Lcd.fillScreen(0x001F);
  Lcd.setTextSize(2);
  Lcd.setCursor(0, 0);
  Lcd.println("Connection to Duet failed.");
  Lcd.println();
  Lcd.println(error_message);
}

static void drawScreenBadResponse() {
  last_screen = SCREEN_BAD_RESPONSE;
  Lcd.fillScreen(0x001F);
  Lcd.setTextSize(2);
  Lcd.setCursor(0, 0);
  Lcd.println("Bad response.");
}


static void drawScreenInfo(const DuetStatus& duet_status) {
  last_screen = SCREEN_INFO;

  //static int updates;
  //updates++;
  //duet_status = duet_parser.GetParsedDuetStatus();
  Serial.println("Decoding status char");
  //const char status_char = duet_status.state_char;
  //status_txt = charToText(status_char);
  const StatusChar* const status_info = decodeStatusChar(duet_status.state_char);
  const int progress_permils = duet_status.progress_permils;
  Serial.println("parser ok");
  Serial.println(duet_status.state_char);
  Serial.println(status_info->c);
  Serial.println(status_info->text);
  Serial.println(status_info->color);
  Serial.println(duet_status.progress_permils);

  Lcd.fillScreen(status_info->color);
  Lcd.setTextColor(BLACK);
  Lcd.setCursor(3, 3, 2);
  Lcd.setTextSize(3);
  //Lcd.printf(updates & 0x1 ? " *" : "* ");

  if (progress_permils) {
    Lcd.setCursor(180, 3, 2);
    Lcd.printf("%d.%d%%", progress_permils / 10, progress_permils % 10);
  }

  Lcd.setCursor(20, 80, 2);
  Lcd.setTextSize(6);
  Lcd.print(status_info->text);
}

void setup() {
  M5.begin();
  Lcd.fillScreen(0x001F);  // blue
  
  Lcd.setTextSize(2);
  Lcd.setTextColor(0xFFE0, 0x001F);
  Lcd.println("Duet Buddy 0.11");
  Lcd.println();

  Lcd.println("Starting serial");
  Lcd.println();

  Serial.begin(115200);
  Serial.println();
//  Serial.println();

  // Give the IDE a chance to connect and reload a
  // new binary.
//  Lcd.printf("Waiting for bootloader\n");
//  for (uint8_t t = 3; t > 0; t--) {
//    Serial.printf("[SETUP] WAIT %d...\n", t);
//    Serial.flush();
//    delay(1000);
//  }


  if (wifiMulti.addAP(CONFIG_SSID, CONFIG_PASSWORD)) {
    drawScreenNoWifi();
    //Lcd.println("Configured Wifi AP");
  } else {
    drawScreenNoSetup();
    //Lcd.println("Invalid Wifi settings");
    //delay(10000);
  }

  delay(1000);

}

//static int updates = 0;

void loop() {
 // return;
  
  if (last_screen == SCREEN_NO_SETUP) {
    delay(500);
    return;
  }

  // wait for WiFi connection
  if ((wifiMulti.run() != WL_CONNECTED)) {
    drawScreenNoWifi();
    delay(500);
    return;
  }

  if (last_screen == SCREEN_NO_WIFI) {
    drawScreenWifiConnected();
    delay(1000);
    return;
  }

  Serial.print("[HTTP] begin...\n");
  http.begin(url);

  Serial.print("[HTTP] GET...\n");
  int httpCode = http.GET();

  if (httpCode != HTTP_CODE_OK) {
    drawScreenNoHttpConnection(http.errorToString(httpCode).c_str());
    http.end();
    delay(500);
    return;
  }


  //  const char** status_txt = "[?];
  //  int progress_permils = 0;
  // httpCode will be negative on error
  //  if (httpCode > 0) {
  // HTTP header has been send and Server response header has been handled
  Serial.printf("[HTTP] GET... code: %d\n", httpCode);

  // Check http response code
  // if (httpCode == HTTP_CODE_OK) {
  // Parse the duet response. This is a json message.
  duet_parser.StartParsingJsonMessage();
  WiFiClient& stream = http.getStream();
  while (stream.available()) {
    int c = stream.read();
    duet_parser.ParseNextChar(c);
    Serial.print(char(c));
  }

  Serial.println("Closing http");
  http.end();

  Serial.println();
  if (!duet_parser.IsParsedMessageOk()) {
    Serial.println("Message not ok");
    drawScreenBadResponse();

    delay(1000);
    return;
  }

  duet_status = duet_parser.GetParsedDuetStatus();
  drawScreenInfo(duet_status);
  delay(3000);
  return;


}

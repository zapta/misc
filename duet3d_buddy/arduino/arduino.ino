// Wifi Duet3D monitor for the M5Stack core.

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

WiFiMulti wifiMulti;
HTTPClient http;
DuetParser duet_parser;
DuetStatus duet_status;

void setup() {

  Serial.begin(115200);

  Serial.println();
  Serial.println();

  // Give the IDE a chance to connect and reload a 
  // new binary.
  for (uint8_t t = 3; t > 0; t--) {
    Serial.printf("[SETUP] WAIT %d...\n", t);
    Serial.flush();
    delay(1000);
  }

  M5.begin();
  M5.Lcd.fillScreen(0x51d);  // dark blue
  wifiMulti.addAP(CONFIG_SSID, CONFIG_PASSWORD);
  Serial.println(url);
}

static int updates = 0;

void loop() {
  // wait for WiFi connection
  if ((wifiMulti.run() == WL_CONNECTED)) {
    Serial.print("[HTTP] begin...\n");
    http.begin(url); 

    Serial.print("[HTTP] GET...\n");
    int httpCode = http.GET();


    int color = 0xffff;
    char status_char = ' ';
    int progress_permils = 0;
    // httpCode will be negative on error
    if (httpCode > 0) {
      // HTTP header has been send and Server response header has been handled
      Serial.printf("[HTTP] GET... code: %d\n", httpCode);

      // Check http response code
      if (httpCode == HTTP_CODE_OK) {
        // Parse the duet response. This is a json message.
        duet_parser.start_parsing_json_message();
        WiFiClient& stream = http.getStream();
        while (stream.available()) {
          int c = stream.read();
          duet_parser.ParseNextChar(c);
          Serial.print(char(c));
        }
        Serial.println();
        if (duet_parser.is_message_ok()) {
          updates++;
          duet_status = duet_parser.get_duet_state();
          status_char = duet_status.state_char;
          progress_permils = duet_status.progress_permils;
          Serial.println("parser ok");
          Serial.println(duet_status.state_char);
          Serial.println(duet_status.progress_permils);

          switch (status_char) {
            case 'I':  color = 0x2589; break;  // green.
            case 'P':  color = 0xe8e4; break;  // red
            case 'B':  color = 0xa254; break;  // violet
            default: color = 0xff80; // yellow
          }
        } else {
          Serial.println("Message not ok");
          color = 0xfd79;  // pink
        }
      }
    } else {
      Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
      color = 0x51d;
    }
    Serial.println("Closing http");
    http.end();

    
    M5.Lcd.fillScreen(color);

    M5.Lcd.setTextColor(BLACK);
    M5.Lcd.setCursor(3, 3, 2);
    M5.Lcd.setTextSize(3);
    M5.Lcd.printf(updates & 0x1 ? " *" : "* ");

    if (progress_permils) {
       M5.Lcd.setCursor(180, 3, 2);
       M5.Lcd.printf("%d.%d%%", progress_permils / 10, progress_permils % 10);
    }

    M5.Lcd.setCursor(150, 80, 2);
    M5.Lcd.setTextSize(6);
    M5.Lcd.printf("%c", status_char);
  }

  Serial.println("End loop");

  delay(3000);
}

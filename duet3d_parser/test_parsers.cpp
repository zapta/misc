// A main() function to test the parser.

// Use this condition to disable this test code in deployment.
#if 1

#include <stdio.h>
#include <string.h>

#include "config_parser.h"
#include "duet_parser.h"
#include "json_parser.h"

// Typical duet status json message. Response from
// http://xx.xx.xx.xx/rr_status?type=3
const char* data1 =
    "{\"status\":\"P\",\"coords\":{\"axesHomed\":[1,1,1],\"wpl\":1,\"xyz\":["
    "185.706,109.165,0.420],\"machine\":[231.752,129.470,0.480],\"extr\":[132."
    "2]},\"speeds\":{\"requested\":20.0,\"top\":16.9},\"currentTool\":0,"
    "\"params\":{\"atxPower\":0,\"fanPercent\":[0,100,0,0,0,0,0,0,0],"
    "\"speedFactor\":100.0,\"extrFactors\":[100.0],\"babystep\":0.060},\"seq\":"
    "0,\"sensors\":{\"probeValue\":0,\"fanRPM\":0},\"temps\":{\"bed\":{"
    "\"current\":40.0,\"active\":40.0,\"standby\":0.0,\"state\":2,\"heater\":0}"
    ",\"current\":[40.0,235.0,2000.0,2000.0,2000.0,2000.0,2000.0,2000.0],"
    "\"state\":[2,2,0,0,0,0,0,0],\"tools\":{\"active\":[[235.0]],\"standby\":[["
    "235.0]]},\"extra\":[{\"name\":\"*MCU\",\"temp\":32.5}]},\"time\":653.0,"
    "\"currentLayer\":1,\"currentLayerTime\":0.0,\"extrRaw\":[124.5],"
    "\"fractionPrinted\":61.4,\"filePosition\":42649,\"firstLayerDuration\":"
    "295."
    "0,\"firstLayerHeight\":0.42,\"printDuration\":408.6,\"warmUpDuration\":"
    "113.6,\"timesLeft\":{\"file\":28313.2,\"filament\":9830.9,\"layer\":0.0}}";

const char* sd_data =
    " {\n"
    "  \"wifi_ssid\" : \"my_wifi\",\n"
    "  \"wifi_password\": \"my_psswd\",\n"
    "  \"duet_ip\":\"10.1.1.45\""
    "}  \n"
    "\n";

static JsonParser json_parser;
static DuetParser duet_parser;
static ConfigParser config_parser;

static void test_duet_parser() {
  printf("\nTesting Duet parser:\n");

  const char* const data = data1;
  json_parser.StartParsing(&duet_parser);
  for (const char* p = data; *p; p++) {
    json_parser.ParseNextChar(*p);
  }

  printf("Is message ok: %d\n", duet_parser.IsParsedMessageOk());
  const DuetStatus& duet_state = duet_parser.ParsedData();
  printf("captured char: %d\n", (int)duet_state.state_char);
  printf("progress: %f percents\n", duet_state.progress_percents);
  printf("z height: %f \n", duet_state.z_height);
  printf("temp1: %f \n", duet_state.temp1);
  printf("temp2: %f \n", duet_state.temp2);
}

static void test_config_parser() {
  printf("\nTesting config parser:\n");
  const char* const data = sd_data;
  json_parser.StartParsing(&config_parser);
  for (const char* p = data; *p; p++) {
    json_parser.ParseNextChar(*p);
  }

  printf("Is message ok: %d\n", config_parser.IsParsedMessageOk());
  const Config& parsed_data = config_parser.ParsedData();
  printf("ssid: [%s]\n", parsed_data.wifi_ssid_.c_str());
  printf("ssid: [%s]\n", parsed_data.wifi_password_.c_str());
  printf("ssid: [%s]\n", parsed_data.duet_ip_.c_str());
}

int main() {
  test_duet_parser();
  test_config_parser();
  printf("All done.\n");
}

#endif

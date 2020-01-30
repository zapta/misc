// A main() function to test the parser. 

// Use this condition to disable this test code in deployment.
#if 1

#include "duet_parser.h"

#include <stdio.h>
#include <string.h>


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
    "\"fractionPrinted\":61.4,\"filePosition\":42649,\"firstLayerDuration\":295."
    "0,\"firstLayerHeight\":0.42,\"printDuration\":408.6,\"warmUpDuration\":"
    "113.6,\"timesLeft\":{\"file\":28313.2,\"filament\":9830.9,\"layer\":0.0}}";

int main() {
  DuetParser duet_parser;

  const char* data = data1;
  //printf("Will process: [%s]\n", data);

  duet_parser.start_parsing_json_message();
  for (const char* p = data; *p; p++) {
    //printf("Next char [%c]\n", *p);
    duet_parser.ParseNextChar(*p);
  }

  printf("Is message ok: %d\n", duet_parser.is_message_ok());
  const DuetStatus duet_state = duet_parser.get_duet_state();
  printf("captured char: %d\n", (int)duet_state.state_char);
  printf("progress: %d permils\n", duet_state.progress_permils);
  printf("All done.\n");
}

#endif

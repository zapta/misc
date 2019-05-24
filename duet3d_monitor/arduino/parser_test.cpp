// TalTest.cpp : This file contains the 'main' function. Program execution
// begins and ends there.
//
#if 0

#include <stdio.h>
#include <string.h>
#include "monitor.h"

const char* data1 =
    "{"
    "\"status\":\"I\","
    "\"heaters\":[18.6,17.8],"
    "\"active\":[0.0,0.0],"
    "\"standby\":[0.0,0.0],"
    "\"hstat\":[0,2],"
    "\"pos\":[0.000,0.000,0.000],"
    "\"machine\":[0.000,0.000,0.000],"
    "\"sfactor\":100.00,"
    "\"efactor\":[100.00],"
    "\"babystep\":0.000,"
    "\"tool\":0,"
    "\"probe\":\"0\","
    "\"fanPercent\":[0.0,0.0,100.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"
    "\"fanRPM\":0,"
    "\"homed\":[0,0,0],"
    "\"msgBox.mode\":-1"
    "}";

const char* data2 =
    "{"
    "\"status\":\"I\","
    "\"heaters\":[10.0,88.8],"  // hot
    "\"active\":[0.0,0.0],"
    "\"standby\":[0.0,0.0],"
    "\"hstat\":[0,2],"
    "\"pos\":[0.000,0.000,0.000],"
    "\"machine\":[0.000,0.000,0.000],"
    "\"sfactor\":100.00,"
    "\"efactor\":[100.00],"
    "\"babystep\":0.000,"
    "\"tool\":0,"
    "\"probe\":\"0\","
    "\"fanPercent\":[0.0,0.0,100.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"
    "\"fanRPM\":0,"
    "\"homed\":[0,0,0],"
    "\"msgBox.mode\":-1"
    "}";

const char* data3 =
    "{"
    "\"status\":\"P\","  // printing
    "\"heaters\":[10.0,15.0],"
    "\"active\":[0.0,0.0],"
    "\"standby\":[0.0,0.0],"
    "\"hstat\":[0,2],"
    "\"pos\":[0.000,0.000,0.000],"
    "\"machine\":[0.000,0.000,0.000],"
    "\"sfactor\":100.00,"
    "\"efactor\":[100.00],"
    "\"babystep\":0.000,"
    "\"tool\":0,"
    "\"probe\":\"0\","
    "\"fanPercent\":[0.0,0.0,100.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"
    "\"fanRPM\":0,"
    "\"homed\":[0,0,0],"
    "\"msgBox.mode\":-1"
    "}";

const char* data4 =
    "{"
    "\"status\":\"I\","
    "\"heaters\":[10.0,x15.0],"  // invalid float
    "\"active\":[0.0,0.0],"
    "\"standby\":[0.0,0.0],"
    "\"hstat\":[0,2],"
    "\"pos\":[0.000,0.000,0.000],"
    "\"machine\":[0.000,0.000,0.000],"
    "\"sfactor\":100.00,"
    "\"efactor\":[100.00],"
    "\"babystep\":0.000,"
    "\"tool\":0,"
    "\"probe\":\"0\","
    "\"fanPercent\":[0.0,0.0,100.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"
    "\"fanRPM\":0,"
    "\"homed\":[0,0,0],"
    "\"msgBox.mode\":-1"
    "}";

const char* data5 =
    "{::"  // invalid json structure
    "\"status\":\"I\","
    "\"heaters\":[10.0,15.0],"
    "\"active\":[0.0,0.0],"
    "\"standby\":[0.0,0.0],"
    "\"hstat\":[0,2],"
    "\"pos\":[0.000,0.000,0.000],"
    "\"machine\":[0.000,0.000,0.000],"
    "\"sfactor\":100.00,"
    "\"efactor\":[100.00],"
    "\"babystep\":0.000,"
    "\"tool\":0,"
    "\"probe\":\"0\","
    "\"fanPercent\":[0.0,0.0,100.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],"
    "\"fanRPM\":0,"
    "\"homed\":[0,0,0],"
    "\"msgBox.mode\":-1"
    "}";

int main() {
  const char* data = data5;
  printf("Will process: [%s]\n", data);

  for (const char* p = data; *p; p++) {
    // printf("Next char [%c]\n", *p);
    monitor::ProcessNextChar(*p);
  }

  for (int i = 0; i < 2; i++) {
    int events = monitor::ConsumePendingEvents();
    printf("\n");
    printf("Errors ...... %s\n", events & monitor::HAD_ERRORS ? "yes" : "no");
    printf("Traffic ..... %s\n", events & monitor::HAD_TRAFFIC ? "yes" : "no");
    printf("Active ...... %s\n",
           events & monitor::REPORTED_ACTIVE ? "yes" : "no");
    printf("Non Active .. %s\n",
           events & monitor::REPORTED_INACTIVE ? "yes" : "no");
  }
}
#endif


#include "monitor.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"

// If true, processing a message. Otherwise, waiting for begining of
// next message
static bool in_message;

// Bit masks of pending events.
static int pending_events = 0;

inline void SetEvent(monitor::Event event) {
  //printf("Setting event: [%d]\n", event);
  pending_events |= event;
}

// Valid while in_message is true. Represents data captured so far.
namespace captured_data {
static int field_count;
static char status_code;
static int heaters_count;
static double max_heater_temp;

static void reset() {
  field_count = 0;
  status_code = '\0';
  heaters_count = 0;
  max_heater_temp = 0.0;
}
}  // namespace captured_data

namespace parser_watcher {

//static void DumpReceivedValue(const char id[], const char val[],
//                              const size_t arrayDepth, const size_t indices[]) {
//  printf("*** Field: [%s] = [%s] [", id, val);
//  for (size_t i = 0; i < arrayDepth; i++) {
//    if (i > 0) {
//      printf(",");
//    }
//    printf("%d", indices[i]);
//  }
//  printf("]\n");
//
//  if (strcmp(id, "status") == 0 && strlen(val) == 1) {
//    printf("##### status -> [%c]\n", val[0]);
//  }
//}

// Json parser encounted a field or array value.
extern void ProcessReceivedValue(const char id[], const char val[],
                                 const size_t arrayDepth, const size_t indices[]) {
  //DumpReceivedValue(id, val, arrayDepth, indices);

  if (!in_message) {
    return;
  }
  captured_data::field_count++;

  // Capture status value
  if (strcmp(id, "status") == 0) {
    if (strlen(val) == 1) {
      captured_data::status_code = val[0];
    } else {
	  // Error. Unexpected 'status' value length.
      SetEvent(monitor::HAD_ERRORS);
      in_message = false; 
    }
    return;
  }

  // Here field is not 'status'.
  // If this is the first field in the message then ignore this message.
  // It can be for example a directory listing message that starts with a 'dir'
  // field.
  if (captured_data::field_count == 1) {
	  // This is not an error, just a packet we don't care about.
    in_message = false;
  }

  // Capture max heater temp
  if (strcmp(id, "heaters^") == 0) {
    char* end_ptr;
    const float temp = strtof(val, &end_ptr);
    if (*end_ptr) {
		// Value format error. 
      SetEvent(monitor::HAD_ERRORS);
      in_message = false;
    }
    if (temp > captured_data::max_heater_temp) {
      captured_data::max_heater_temp = temp;
    }
    captured_data::heaters_count++;
    return;
  }
}  // namespace parser_watcher

// Parser exited an array.
extern void ProcessArrayEnd(const char id[],
                            const size_t arrayDepth,  const size_t indices[]) {
 // printf("*** Array End\n");
}

// Received a begining of a json message. This may or may not be a status
// report message.
extern void StartReceivedMessage() {
  //printf("*** Message Start\n");
  captured_data::reset();
  in_message = true;
}

// Recieved an end of a json message.
void EndReceivedMessage() {
  //printf("*** Message End\n");
  if (in_message) {

    //printf("###### EOM  status=[%c], heaters=[%d], max_temp=[%f]\n",
    //       captured_data::status_code, captured_data::heaters_count,
    //       captured_data::max_heater_temp);

    // Error if message doesn't pass sanity check.
    if (!captured_data::status_code || captured_data::field_count < 10 ||
        captured_data::heaters_count < 1) {
      SetEvent(monitor::HAD_ERRORS);

    } else if (captured_data::status_code == 'I' &&
               captured_data::max_heater_temp < 70.0) {
      SetEvent(monitor::REPORTED_INACTIVE);
    } else {
      SetEvent(monitor::REPORTED_ACTIVE);
    }
    in_message = false;
  }
}

// Traffic parser reported an error.
void ProcessError() { SetEvent(monitor::HAD_ERRORS); }

}  // namespace parser_watcher

namespace monitor {
void ProcessNextChar(const char c) {
  SetEvent(monitor::HAD_TRAFFIC);
  parser::ProcessNextChar(c);
}

int ConsumePendingEvents() {
  const int result = pending_events;
  pending_events = 0;
  return result;
}
}  // namespace monitor

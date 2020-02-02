// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#include "duet_parser.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "json_parser.h"

// TODO: move GetUnsignedInteger and GetFloat to a common util file.

// Try to get an unsigned integer value from a string.
// Return true if ok. If false, rstl is left as is.
static bool GetUnsignedInteger(const char s[], unsigned int* rslt) {
  if (s[0] == 0) return false;  // empty string
  char* endptr;
  unsigned int temp;
  temp = (unsigned int)strtoul(s, &endptr, 10);
  if (*endptr) {
    return false;
  }
  *rslt = temp;
  return true;
}

// Try to get a floating point value from a string. if it is actually a floating
// point value, round it.
// Return true if ok. If false, rstl is left as is.
static bool GetFloat(const char s[], float* rslt) {
  if (s[0] == 0) return false;  // empty string

  // GNU strtod is buggy, it's very slow for some long inputs, and some versions
  // have a buffer overflow bug. We presume strtof may be buggy too. Tame it by
  // rejecting any strings that much longer than we expect to receive.
  if (strlen(s) > 10) return false;

  char* endptr;
  float temp;
  temp = strtof(s, &endptr);
  if (*endptr) {
    return false;
  }
  *rslt = temp;
  return true;
}

void DuetParser::OnStartParsing() {
  duet_parser_state_ = DuetParserState::IDLE;
  captured_duet_status_.reset();
}

// Utility for message events preconditions.
bool DuetParser::CheckExpectedState(DuetParserState expected_state) {
  if (duet_parser_state_ == expected_state) {
    return true;
  }
  duet_parser_state_ = DuetParserState::ERROR;
  return false;
}

// Json parser encounted a field or array value.
void DuetParser::OnReceivedValue(const char id[], const char val[],
                                 const int arrayDepth, const int indices[]) {
  if (!CheckExpectedState(DuetParserState::IN_MESSAGE)) {
    return;
  }

  //printf("Id: [%s] -> [%s]  (%d, [%d, %d, %d])\n", id, val, arrayDepth,
  //       indices[0], indices[1], indices[2]);

  // Capture duet status char.
  if (strcmp(id, "status") == 0) {
    if (strlen(val) == 1) {
      captured_duet_status_.state_char = val[0];
    } else {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  if (strcmp(id, "fractionPrinted") == 0) {
    if (!GetFloat(val, &captured_duet_status_.progress_percents)) {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  if (strcmp(id, "coords:xyz^") == 0 && indices[0] == 2) {
    if (!GetFloat(val, &captured_duet_status_.z_height)) {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  if (strcmp(id, "temps:current^") == 0) {
    if (indices[0] == 0) {
      if (!GetFloat(val, &captured_duet_status_.temp1)) {
        duet_parser_state_ = DuetParserState::ERROR;
      }
    }
    else if (indices[0] == 1) {
      if (!GetFloat(val, &captured_duet_status_.temp2)) {
        duet_parser_state_ = DuetParserState::ERROR;
      }
    }
    return;
  }


  // Else, ignored.
}

// Parser exited an array.
void DuetParser::OnArrayEnd(const char id[], const int arrayDepth,
                            const int indices[]) {
  if (!CheckExpectedState(DuetParserState::IN_MESSAGE)) {
    return;
  }
}

// Received a begining of a json message. This may or may not be a status
// report message.
void DuetParser::OnStartReceivedMessage() {
  if (!CheckExpectedState(DuetParserState::IDLE)) {
    return;
  }
  duet_parser_state_ = DuetParserState::IN_MESSAGE;
}

// Recieved an end of a json message.
void DuetParser::OnEndReceivedMessage() {
  if (!CheckExpectedState(DuetParserState::IN_MESSAGE)) {
    return;
  }
  duet_parser_state_ = DuetParserState::MESSAGE_DONE;
}

// Traffic parser reported an error.
void DuetParser::OnError() {
  CheckExpectedState(DuetParserState::ERROR);
}

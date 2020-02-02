// Implementation of duet_parser.h.

#include "duet_parser.h"
#include "json_parser.h"

#include <stdlib.h>
#include <string.h>

// Try to get an unsigned integer value from a string
bool GetUnsignedInteger(const char s[], unsigned int& rslt) {
  if (s[0] == 0) return false;  // empty string
  char* endptr;
  rslt = (int)strtoul(s, &endptr, 10);
  return *endptr == 0;
}

// Try to get a floating point value from a string. if it is actually a floating
// point value, round it.
bool GetFloat(const char s[], float& rslt) {
  if (s[0] == 0) return false;  // empty string

  // GNU strtod is buggy, it's very slow for some long inputs, and some versions
  // have a buffer overflow bug. We presume strtof may be buggy too. Tame it by
  // rejecting any strings that much longer than we expect to receive.
  if (strlen(s) > 10) return false;

  char* endptr;
  rslt = strtof(s, &endptr);
  return *endptr == 0;  // we parsed a float
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

  // Capture duet status char.
  if (strcmp(id, "status") == 0) {
    if (strlen(val) == 1) {
      captured_duet_status_.state_char = val[0];
    } else {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  // Capture print progress.
  if (strcmp(id, "fractionPrinted") == 0) {
    float percents;
    if (GetFloat(val, percents)) {
      captured_duet_status_.progress_permils = (int)(percents * 10);
    } else {
      duet_parser_state_ = DuetParserState::ERROR;
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
void DuetParser::OnError() { CheckExpectedState(DuetParserState::ERROR); }

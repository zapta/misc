// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#include "config_parser.h"

#include <stdlib.h>
#include <string.h>

#include "json_parser.h"



void ConfigParser::OnStartParsing() {
  config_parser_state_ = ConfigParserState::IDLE;
  captured_config_.reset();
}

// Utility for message events preconditions.
bool ConfigParser::CheckExpectedState(
  ConfigParserState expected_state) {
  if (config_parser_state_ == expected_state) {
    return true;
  }
  config_parser_state_ = ConfigParserState::ERROR;
  return false;
}

// Json parser encounted a field or array value.
void ConfigParser::OnReceivedValue(const char id[], const char val[],
                                   const int arrayDepth,
                                   const int indices[]) {
  if (!CheckExpectedState(ConfigParserState::IN_MESSAGE)) {
    return;
  }

  if (strcmp(id, "wifi_ssid") == 0) {
    captured_config_.wifi_ssid = val;
    return;
  }

  if (strcmp(id, "wifi_password") == 0) {
    captured_config_.wifi_password = val;
    return;
  }

  if (strcmp(id, "status_url") == 0) {
    captured_config_.status_url = val;
    return;
  }

  // Else, ignored.
}

// Parser exited an array.
void ConfigParser::OnArrayEnd(const char id[], const int arrayDepth,
                              const int indices[]) {
  if (!CheckExpectedState(ConfigParserState::IN_MESSAGE)) {
    return;
  }
}

// Received a begining of a json message. This may or may not be a status
// report message.
void ConfigParser::OnStartReceivedMessage() {
  if (!CheckExpectedState(ConfigParserState::IDLE)) {
    return;
  }
  config_parser_state_ = ConfigParserState::IN_MESSAGE;
}

// Recieved an end of a json message.
void ConfigParser::OnEndReceivedMessage() {
  if (!CheckExpectedState(ConfigParserState::IN_MESSAGE)) {
    return;
  }
  config_parser_state_ = ConfigParserState::MESSAGE_DONE;
}

// Traffic parser reported an error.
void ConfigParser::OnError() {
  CheckExpectedState(ConfigParserState::ERROR);
}

/* void DuetParser::ParseNextChar(const char c) {
   json_parser_.ParseNextChar(c);
  }*/

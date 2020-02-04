// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#include "duet_parser.h"

#include <stdio.h>
#include <string.h>

#include "json_parser.h"
#include "parser_utils.h"


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
    if (!StringToFloat(val, &captured_duet_status_.progress_percents)) {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  if (strcmp(id, "coords:xyz^") == 0 && indices[0] == 2) {
    if (!StringToFloat(val, &captured_duet_status_.z_height)) {
      duet_parser_state_ = DuetParserState::ERROR;
    }
    return;
  }

  if (strcmp(id, "temps:current^") == 0) {
    if (indices[0] == 0) {
      if (!StringToFloat(val, &captured_duet_status_.temp1)) {
        duet_parser_state_ = DuetParserState::ERROR;
      }
    }
    else if (indices[0] == 1) {
      if (!StringToFloat(val, &captured_duet_status_.temp2)) {
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

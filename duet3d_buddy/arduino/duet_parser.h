// Parser for the duet json status responses. These
// are the HTTP responses that the duet return for the URL
// http://xx.xx.xx.xx/rr_status?type=3

#ifndef DUET_PARSER_H
#define DUET_PARSER_H

#include "json_parser.h"

// Parsed values.
struct DuetStatus {
  char state_char;
  int progress_permils;

  void reset() {
    // Default values.
    state_char = ' ';
    progress_permils = 0;
  }
};

class DuetParser : public JsonParserListener {
  public:
    //void Reset();

    // Methods for callbacks from the json parse.
    virtual void OnStartParsing();

    virtual void OnReceivedValue(const char id[], const char val[],
                                 const int arrayDepth, const int indices[]);

    virtual void OnArrayEnd(const char id[], const int arrayDepth,
                            const int indices[]);

    virtual void OnStartReceivedMessage();
    virtual void OnEndReceivedMessage();
    virtual void OnError();

    // Methods for clients
    bool IsParsedMessageOk() {
      return duet_parser_state_ == MESSAGE_DONE;
    }

    // If the message parsed ok, call this to access internal parsed data.
    const DuetStatus& ParsedData() {
      return captured_duet_status_;
    }

    // For debugging
    int State() {
      return duet_parser_state_;
    }

  private:
    enum DuetParserState { IDLE = 1, IN_MESSAGE, MESSAGE_DONE, ERROR };

    bool CheckExpectedState(DuetParserState expected_state);

    DuetParserState duet_parser_state_;
    DuetStatus captured_duet_status_;
};


#endif

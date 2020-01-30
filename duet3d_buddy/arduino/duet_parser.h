// Parse for the duet status json message. These are the 
// messages returned from GET requests to 
// http://xx.xx.xx.xx/rr_status?type=3


#ifndef DUET_PARSER_H
#define DUET_PARSER_H

#include "json_parser.h"

// Represents parsed duet status.
struct DuetStatus {
  char state_char;
  int progress_permils;

  void reset() {
    // Default values.
    state_char = ' ';
    progress_permils = 0;
  }
};

// Internal implementation of the duet parser. This class
// is used to handle events from the json parser.
class JsonParserListenerImpl : public JsonParserListener {
 public:
  void Reset();

  virtual void OnReceivedValue(const char id[], const char val[],
                               const int arrayDepth, const int indices[]);

  virtual void OnArrayEnd(const char id[], const int arrayDepth,
                          const int indices[]);

  virtual void OnStartReceivedMessage();
  virtual void OnEndReceivedMessage();
  virtual void OnError();

 private:
  enum DuetParserState { IDLE = 1, IN_MESSAGE, MESSAGE_DONE, ERROR };
  bool CheckExpectedState(DuetParserState expected_state);

  DuetParserState duet_parser_state_;
  DuetStatus captured_duet_status_;

  friend class DuetParser;
};

// Public API of the duet status reponse parser. Same 
// instance can be used for an unlimited of message
// parsings.
class DuetParser {
 public:
  // Start parsing a new json message.
  void StartParsingJsonMessage();
  // Prase the next char of the json message.
  void ParseNextChar(const char c);

  // Call this to check if the message was parsed ok.
  bool IsParsedMessageOk() {
    return json_listener_impl_.duet_parser_state_ ==
           JsonParserListenerImpl::MESSAGE_DONE;
  }
  // If the message parsed ok, call this to get the parsed data.
  const DuetStatus GetParsedDuetStatus() {
    return json_listener_impl_.captured_duet_status_;
  }

 private:
  JsonParserListenerImpl json_listener_impl_;
  JsonParser json_parser_;
};

#endif

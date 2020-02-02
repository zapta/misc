// Json parse. A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Hardware/SerialIo.hpp

#ifndef JSON_PARSER_H
#define JSON_PARSER_H

#include "simple_string.h"

// Interface of a json event callbacks handler.
class JsonParserListener {
  public:
    virtual void OnStartParsing() = 0;
    virtual void OnReceivedValue(const char id[], const char val[],
                                 const int arrayDepth, const int indices[]) = 0;

    virtual void OnArrayEnd(const char id[], const int arrayDepth,
                            const int indices[]) = 0;

    virtual void OnStartReceivedMessage() = 0;
    virtual void OnEndReceivedMessage() = 0;
    virtual void OnError() = 0;
};

// The json parser. A single instance can be used for to parse
// an unlimited number of messages.
class JsonParser {
  public:
    // Start parsing a new json message. Use given listener for callbacks.
    void StartParsing(JsonParserListener* listener);
    void ParseNextChar( char c);

  private:
    static const int MAX_ARRAY_NESTING = 4;

    // Enumeration to represent the json parsing state.
    // We don't allow nested objects or nested arrays, so we don't need a state
    // stack. An additional variable elementCount is 0 if we are not in an
    // array, else the number of elements we have found (including the current
    // one)
    enum JsonState {
      jsBegin,         // initial state, expecting '{'
      jsExpectId,      // just had '{' so expecting a quoted ID
      jsId,            // expecting an identifier, or in the middle of one
      jsHadId,         // had a quoted identifier, expecting ':'
      jsVal,           // had ':', expecting value
      jsStringVal,     // had '"' and expecting or in a string value
      jsStringEscape,  // just had backslash in a string
      jsIntVal,        // receiving an integer value
      jsNegIntVal,     // had '-' so expecting a integer value
      jsFracVal,       // receiving a fractional value
      jsEndVal,  // had the end of a string or array value, expecting comma or ]
      // or
      // }
      jsError  // something went wrong
    };

    // Utility methods.
    JsonState JsError();
    void RemoveLastId();
    void RemoveLastIdChar();
    bool InArray();
    void ProcessField();
    void EndArray();
    void ConvertUnicode();

    JsonState state_ = jsBegin;
    SimpleString<50> field_id_;
    SimpleString<300> field_val_;  // long enough for about 6 lines of message
    int array_depth_ = 0;
    int array_indices_[MAX_ARRAY_NESTING];
    JsonParserListener* json_listener_ = nullptr;
};

#endif

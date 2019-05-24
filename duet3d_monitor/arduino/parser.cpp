// PanelDue serial communication message parser.
//
// A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Hardware/SerialIo.cpp

#include "parser.h"
#include <stdio.h>
#include "simple_string.hpp"

namespace parser {

const int MAX_ARRAY_NESTING = 4;

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
  jsError    // something went wrong
};

static JsonState state = jsBegin;

inline JsonState JsError() {
  parser_watcher::ProcessError();
  return jsError;
}

// fieldId is the path of a value being received. A '^' character indicates
// the position of an array index, and a ':' character indicates a field
// separator.
static String<50>  fieldId;
static String<300> fieldVal;  // long enough for about 6 lines of message

static int arrayDepth = 0;
static int arrayIndices[MAX_ARRAY_NESTING];

static void RemoveLastId() {
  int index = fieldId.size();
  while (index != 0 && fieldId[index - 1] != '^' && fieldId[index - 1] != ':') {
    --index;
  }
  fieldId.truncate(index);
}

static void RemoveLastIdChar() {
  if (fieldId.size() != 0) {
    fieldId.truncate(fieldId.size() - 1);
  }
}

static bool InArray() {
  return fieldId.size() > 0 && fieldId[fieldId.size() - 1] == '^';
}

static void ProcessField() {
  parser_watcher::ProcessReceivedValue(fieldId.c_str(), fieldVal.c_str(),
                                       arrayDepth, arrayIndices);
  fieldVal.clear();
}

static void EndArray() {
  parser_watcher::ProcessArrayEnd(fieldId.c_str(), arrayDepth, arrayIndices);
  if (arrayDepth != 0)  // should always be true
  {
    --arrayDepth;
    RemoveLastIdChar();
  }
}

// Look for combining characters in the string value and convert them if
// possible
static void ConvertUnicode() {
  // Not needed for our simple application.
}

void ProcessNextChar(char c) {
  if (c == '\n') {
    state = jsBegin;  // abandon current parse (if any) and start again
    return;
  }

  switch (state) {
    case jsBegin:  // initial state, expecting '{'
      if (c == '{') {
        parser_watcher::StartReceivedMessage();
        state = jsExpectId;
        fieldVal.clear();
        fieldId.clear();
        arrayDepth = 0;
      }
      break;

    case jsExpectId:  // expecting a quoted ID
      switch (c) {
        case ' ':  // ignore space
          break;
        case '"':
          state = jsId;
          break;
        case '}':  // empty object, or extra comma at end of field list
          RemoveLastId();
          if (fieldId.size() == 0) {
            // TODO: should we report this to the monitor as an error?
            parser_watcher::EndReceivedMessage();
            state = jsBegin;
          } else {
            RemoveLastIdChar();
            state = jsEndVal;
          }
          break;
        default:
          state = JsError();
          break;
      }
      break;

    case jsId:  // expecting an identifier, or in the middle of one
      switch (c) {
        case '"':
          state = jsHadId;
          break;
        default:
          if (c < ' ') {
            state = JsError();
          } else if (c != ':' && c != '^') {
            if (!fieldId.add(c)) {
              state = JsError();
            }
          }
          break;
      }
      break;

    case jsHadId:  // had a quoted identifier, expecting ':'
      switch (c) {
        case ':':
          state = jsVal;
          break;
        case ' ':
          break;
        default:
          state = JsError();
          break;
      }
      break;

    case jsVal:  // had ':' or ':[', expecting value
      switch (c) {
        case ' ':
          break;
        case '"':
          fieldVal.clear();
          state = jsStringVal;
          break;
        case '[':
          if (arrayDepth < MAX_ARRAY_NESTING && fieldId.add('^')) {
            arrayIndices[arrayDepth] = 0;  // start an array
            ++arrayDepth;
          } else {
            state = JsError();
          }
          break;
        case ']':
          if (InArray()) {
            EndArray();  // empty array
            state = jsEndVal;
          } else {
            state = JsError();  // ']' received without a matching '[' first
          }
          break;
        case '-':
          fieldVal.clear();
          // TODO: an report error to the watcher
          state = (fieldVal.add(c)) ? jsNegIntVal : JsError();
          break;
        case '{':  // start of a nested object
                   // TODO: report an error to the watcher
          state = (fieldId.add(':')) ? jsExpectId : JsError();
          break;
        default:
          if (c >= '0' && c <= '9') {
            fieldVal.clear();
            fieldVal.add(c);  // must succeed because we just cleared fieldVal
            state = jsIntVal;
            break;
          } else {
            state = JsError();
          }
      }
      break;

    case jsStringVal:  // just had '"' and expecting a string value
      switch (c) {
        case '"':
          ConvertUnicode();
          ProcessField();
          state = jsEndVal;
          break;
        case '\\':
          state = jsStringEscape;
          break;
        default:
          if (c < ' ') {
            state = JsError();
          } else {
            fieldVal.add(c);  // ignore any error so that long string parameters
                              // just get truncated
          }
          break;
      }
      break;

    case jsStringEscape:  // just had backslash in a string
      if (!fieldVal.full()) {
        switch (c) {
          case '"':
          case '\\':
          case '/':
            if (!fieldVal.add(c)) {
              state = JsError();
            }
            break;
          case 'n':
          case 't':
            if (!fieldVal.add(' '))  // replace newline and tab by space
            {
              // parser_watcher::ProcessError();

              state = JsError();
            }
            break;
          case 'b':
          case 'f':
          case 'r':
          default:
            break;
        }
      }
      state = jsStringVal;
      break;

    case jsNegIntVal:  // had '-' so expecting a integer value
                       // TODO: report an error to the watcher
      state = (c >= '0' && c <= '9' && fieldVal.add(c)) ? jsIntVal : JsError();
      break;

    case jsIntVal:  // receiving an integer value
      switch (c) {
        case '.':
          state = (fieldVal.add(c)) ? jsFracVal : JsError();
          break;
        case ',':
          ProcessField();
          if (InArray()) {
            ++arrayIndices[arrayDepth - 1];
            fieldVal.clear();
            state = jsVal;
          } else {
            RemoveLastId();
            state = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ProcessField();
            ++arrayIndices[arrayDepth - 1];
            EndArray();
            state = jsEndVal;
          } else {
            state = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state = JsError();
          } else {
            ProcessField();
            RemoveLastId();
            if (fieldId.size() == 0) {
              parser_watcher::EndReceivedMessage();
              state = jsBegin;
            } else {
              RemoveLastIdChar();
              state = jsEndVal;
            }
          }
          break;
        default:
          if (!(c >= '0' && c <= '9' && fieldVal.add(c))) {
            state = JsError();
          }
          break;
      }
      break;

    case jsFracVal:  // receiving a fractional value
      switch (c) {
        case ',':
          ProcessField();
          if (InArray()) {
            ++arrayIndices[arrayDepth - 1];
            state = jsVal;
          } else {
            RemoveLastId();
            state = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ProcessField();
            ++arrayIndices[arrayDepth - 1];
            EndArray();
            state = jsEndVal;
          } else {
            state = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state = JsError();
          } else {
            ProcessField();
            RemoveLastId();
            if (fieldId.size() == 0) {
              parser_watcher::EndReceivedMessage();
              state = jsBegin;
            } else {
              RemoveLastIdChar();
              state = jsEndVal;
            }
          }
          break;
        default:
          if (!(c >= '0' && c <= '9' && fieldVal.add(c))) {
            state = JsError();
          }
          break;
      }
      break;

    case jsEndVal:  // had the end of a string or array value, expecting comma
                    // or ] or }
      switch (c) {
        case ',':
          if (InArray()) {
            ++arrayIndices[arrayDepth - 1];
            fieldVal.clear();
            state = jsVal;
          } else {
            RemoveLastId();
            state = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ++arrayIndices[arrayDepth - 1];
            EndArray();
          } else {
            state = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state = JsError();
          } else {
            RemoveLastId();
            if (fieldId.size() == 0) {
              parser_watcher::EndReceivedMessage();
              state = jsBegin;
            } else {
              RemoveLastIdChar();
              // state = jsEndVal;     // not needed, state == jsEndVal already
            }
          }
          break;
        default:
          break;
      }
      break;

    case jsError:
      // Ignore all characters. State will be reset to jsBegin at the start of
      // this function when we receive a newline.
      break;
  }
}

}  // namespace parser

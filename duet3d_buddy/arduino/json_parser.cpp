// Json parser. A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Hardware/SerialIo.cpp

#include "json_parser.h"
#include "simple_string.h"

JsonParser::JsonState JsonParser::JsError() {
  json_listener_->OnError();
  return jsError;
}

void JsonParser::StartParsing(JsonParserListener* listener) {
  state_ = jsBegin;
  field_id_.clear();
  field_val_.clear();
  array_depth_ = 0;
  json_listener_ = listener;
  json_listener_->OnStartParsing();
}

void JsonParser::RemoveLastId() {
  int index = field_id_.size();
  while (index != 0 && field_id_[index - 1] != '^' && field_id_[index - 1] != ':') {
    --index;
  }
  field_id_.truncate(index);
}

void JsonParser::RemoveLastIdChar() {
  if (field_id_.size() != 0) {
    field_id_.truncate(field_id_.size() - 1);
  }
}

bool JsonParser::InArray() {
  return field_id_.size() > 0 && field_id_[field_id_.size() - 1] == '^';
}

void JsonParser::ProcessField() {
  json_listener_->OnReceivedValue(field_id_.c_str(), field_val_.c_str(), array_depth_,
                                  array_indices_);
  field_val_.clear();
}

void JsonParser::EndArray() {
  json_listener_->OnArrayEnd(field_id_.c_str(), array_depth_, array_indices_);
  if (array_depth_ != 0)  // should always be true
  {
    --array_depth_;
    RemoveLastIdChar();
  }
}

// Look for combining characters in the string value and convert them if
// possible
void JsonParser::ConvertUnicode() {
  // Not needed for our limited application.
}

void JsonParser::ParseNextChar( char c) {
  // Line break characters are treated as white spaces.
  if (c == '\n' || c == '\r') {
    c = ' ';
  }

  switch (state_) {
    case jsBegin:  // initial state, expecting '{'
      if (c == '{') {
        json_listener_->OnStartReceivedMessage();
        state_ = jsExpectId;
        field_val_.clear();
        field_id_.clear();
        array_depth_ = 0;
      }
      break;

    case jsExpectId:  // expecting a quoted ID
      switch (c) {
        case ' ':  // ignore space
          break;
        case '"':
          state_ = jsId;
          break;
        case '}':  // empty object, or extra comma at end of field list
          RemoveLastId();
          if (field_id_.size() == 0) {
            json_listener_->OnEndReceivedMessage();
            state_ = jsBegin;
          } else {
            RemoveLastIdChar();
            state_ = jsEndVal;
          }
          break;
        default:
          state_ = JsError();
          break;
      }
      break;

    case jsId:  // expecting an identifier, or in the middle of one
      switch (c) {
        case '"':
          state_ = jsHadId;
          break;
        default:
          if (c < ' ') {
            state_ = JsError();
          } else if (c != ':' && c != '^') {
            if (!field_id_.add(c)) {
              state_ = JsError();
            }
          }
          break;
      }
      break;

    case jsHadId:  // had a quoted identifier, expecting ':'
      switch (c) {
        case ':':
          state_ = jsVal;
          break;
        case ' ':
          break;
        default:
          state_ = JsError();
          break;
      }
      break;

    case jsVal:  // had ':' or ':[', expecting value
      switch (c) {
        case ' ':
          break;
        case '"':
          field_val_.clear();
          state_ = jsStringVal;
          break;
        case '[':
          if (array_depth_ < MAX_ARRAY_NESTING && field_id_.add('^')) {
            array_indices_[array_depth_] = 0;  // start an array
            ++array_depth_;
          } else {
            state_ = JsError();
          }
          break;
        case ']':
          if (InArray()) {
            EndArray();  // empty array
            state_ = jsEndVal;
          } else {
            state_ = JsError();  // ']' received without a matching '[' first
          }
          break;
        case '-':
          field_val_.clear();
          state_ = (field_val_.add(c)) ? jsNegIntVal : JsError();
          break;
        case '{':  // start of a nested object
          state_ = (field_id_.add(':')) ? jsExpectId : JsError();
          break;
        default:
          if (c >= '0' && c <= '9') {
            field_val_.clear();
            field_val_.add(c);  // must succeed because we just cleared fieldVal
            state_ = jsIntVal;
            break;
          } else {
            state_ = JsError();
          }
      }
      break;

    case jsStringVal:  // just had '"' and expecting a string value
      switch (c) {
        case '"':
          ConvertUnicode();
          ProcessField();
          state_ = jsEndVal;
          break;
        case '\\':
          state_ = jsStringEscape;
          break;
        default:
          if (c < ' ') {
            state_ = JsError();
          } else {
            field_val_.add(c);  // ignore any error so that long string parameters
            // just get truncated
          }
          break;
      }
      break;

    case jsStringEscape:  // just had backslash in a string
      if (!field_val_.full()) {
        switch (c) {
          case '"':
          case '\\':
          case '/':
            if (!field_val_.add(c)) {
              state_ = JsError();
            }
            break;
          case 'n':
          case 't':
            if (!field_val_.add(' '))  // replace newline and tab by space
            {
              state_ = JsError();
            }
            break;
          case 'b':
          case 'f':
          case 'r':
          default:
            break;
        }
      }
      state_ = jsStringVal;
      break;

    case jsNegIntVal:  // had '-' so expecting a integer value
      state_ = (c >= '0' && c <= '9' && field_val_.add(c)) ? jsIntVal : JsError();
      break;

    case jsIntVal:  // receiving an integer value
      switch (c) {
        case '.':
          state_ = (field_val_.add(c)) ? jsFracVal : JsError();
          break;
        case ',':
          ProcessField();
          if (InArray()) {
            ++array_indices_[array_depth_ - 1];
            field_val_.clear();
            state_ = jsVal;
          } else {
            RemoveLastId();
            state_ = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ProcessField();
            ++array_indices_[array_depth_ - 1];
            EndArray();
            state_ = jsEndVal;
          } else {
            state_ = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state_ = JsError();
          } else {
            ProcessField();
            RemoveLastId();
            if (field_id_.size() == 0) {
              json_listener_->OnEndReceivedMessage();
              state_ = jsBegin;
            } else {
              RemoveLastIdChar();
              state_ = jsEndVal;
            }
          }
          break;
        default:
          if (!(c >= '0' && c <= '9' && field_val_.add(c))) {
            state_ = JsError();
          }
          break;
      }
      break;

    case jsFracVal:  // receiving a fractional value
      switch (c) {
        case ',':
          ProcessField();
          if (InArray()) {
            ++array_indices_[array_depth_ - 1];
            state_ = jsVal;
          } else {
            RemoveLastId();
            state_ = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ProcessField();
            ++array_indices_[array_depth_ - 1];
            EndArray();
            state_ = jsEndVal;
          } else {
            state_ = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state_ = JsError();
          } else {
            ProcessField();
            RemoveLastId();
            if (field_id_.size() == 0) {
              json_listener_->OnEndReceivedMessage();
              state_ = jsBegin;
            } else {
              RemoveLastIdChar();
              state_ = jsEndVal;
            }
          }
          break;
        default:
          if (!(c >= '0' && c <= '9' && field_val_.add(c))) {
            state_ = JsError();
          }
          break;
      }
      break;

    case jsEndVal:  // had the end of a string or array value, expecting comma
      // or ] or }
      switch (c) {
        case ',':
          if (InArray()) {
            ++array_indices_[array_depth_ - 1];
            field_val_.clear();
            state_ = jsVal;
          } else {
            RemoveLastId();
            state_ = jsExpectId;
          }
          break;
        case ']':
          if (InArray()) {
            ++array_indices_[array_depth_ - 1];
            EndArray();
          } else {
            state_ = JsError();
          }
          break;
        case '}':
          if (InArray()) {
            state_ = JsError();
          } else {
            RemoveLastId();
            if (field_id_.size() == 0) {
              json_listener_->OnEndReceivedMessage();
              state_ = jsBegin;
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

//}  // namespace parser

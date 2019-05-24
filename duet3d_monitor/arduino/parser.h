// PanelDue serial communication message parser.
//
// A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Hardware/SerialIo.hpp

#ifndef PARSER_H
#define PARSER_H

// Parser's callback methods. Implemented by monitor.cpp.
namespace parser_watcher {
extern void ProcessReceivedValue(const char id[], const char val[],
                                 const int arrayDepth,
                                 const int indices[]);
extern void ProcessArrayEnd(const char id[], const int arrayDepth,
                            const int indices[]);
extern void StartReceivedMessage();
extern void EndReceivedMessage();
extern void ProcessError();

}  // namespace parser_watcher

namespace parser {
extern void ProcessNextChar(char c);
}  // namespace parser

#endif

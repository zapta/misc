#ifndef PARSER_H
#define PARSER_H

// Parser's callback methods. Implemented by monitor.cpp.
namespace parser_watcher {
extern void ProcessReceivedValue(const char id[], const char val[],
                                 const size_t arrayDepth, const size_t indices[]);
extern void ProcessArrayEnd(const char id[],
                            const size_t arrayDepth, const size_t indices[]);
extern void StartReceivedMessage();
extern void EndReceivedMessage();
extern void ProcessError();

}  // namespace parser_watcher

namespace parser {
extern void ProcessNextChar(char c);
}  // namespace parser

#endif

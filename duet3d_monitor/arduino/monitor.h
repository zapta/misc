// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#ifndef MONITOR_H
#define MONITOR_H

namespace monitor {
enum Event {
  HAD_ERRORS       = 0b00001,  // 1
  HAD_TRAFFIC      = 0b00010,  // 2
  REPORTED_ACTIVE  = 0b00100,  // 4
  REPORTED_COOLING = 0b01000,  // 8
  REPORTED_AT_REST = 0b10000,  // 16
};

extern void ProcessNextChar(char c);

// Return a bit mask of events since last call to this function.
extern int ConsumePendingEvents();

}  // namespace monitor

#endif

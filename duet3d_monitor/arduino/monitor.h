// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#ifndef MONITOR_H
#define MONITOR_H

namespace monitor {
enum Event {
  HAD_ERRORS = 1 << 0, // 1
  HAD_TRAFFIC = 1 << 1, // 2
  REPORTED_ACTIVE = 1 << 2,  // 4
  REPORTED_INACTIVE = 1 << 3,  // 8
};

extern void ProcessNextChar(char c);

// Return a bit mask of events since last call to this function.
extern int ConsumePendingEvents();

}  // namespace monitor

#endif

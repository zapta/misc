// Duet state monitor. Parses the sniffed PanelDue serial communication
// and extracts the Duet state.

#ifndef MONITOR_H
#define MONITOR_H

namespace monitor {
enum Event {
  HAD_ERRORS = 1 << 0,
  HAD_TRAFFIC = 1 << 2,
  REPORTED_ACTIVE = 1 << 3,
  REPORTED_INACTIVE = 1 << 4
};

extern void ProcessNextChar(char c);

// Return a bit mask of events since last call to this function.
extern int ConsumePendingEvents();

}  // namespace monitor

#endif

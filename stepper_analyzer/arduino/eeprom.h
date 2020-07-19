

#ifndef EEPROM_H
#define EEPROM_H

#include <arduino.h>
#include "acquisition.h"

namespace eeprom {

void GetAcqSettings(acquisition::Settings* acq_settings);
void UpdateAcqSettings(const acquisition::Settings& acq_settings);

}  // namespace eeprom

#endif

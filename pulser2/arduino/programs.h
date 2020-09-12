
#ifndef PROGRAMS__H
#define PROGRAMS__H

#include <arduino.h>

namespace programs {
class Program {
  public:
    virtual void setup() = 0;
    virtual void loop() = 0;
};

class Program0 : public Program {
  public:
    virtual void setup();
    virtual void loop();
};

class Program1 : public Program {
  public:
    virtual void setup();
    virtual void loop();
};

} // namespace programs

#endif // PROGRAMS__H


#ifndef PROGRAMS__H
#define PROGRAMS__H

#include <arduino.h>


class Program {
  public:
    virtual void setup() = 0;
    virtual void loop() = 0;
};

class Program_0 : public Program {
  public:
    virtual void setup();
    virtual void loop();
};

class Program_1 : public Program {
  public:
    virtual void setup();
    virtual void loop();
};


#endif // PROGRAMS__H

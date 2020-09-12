
#ifndef IO__H
#define IO__H

#include <arduino.h>

namespace io {

// ===== Digital inputs

class DigitalInPin {
  public:
    // Inverted if on_level == false.
    DigitalInPin(PORT_struct& port, uint8_t bit_index, bool on_level)
      : port_(port), bit_mask_(1 << bit_index), on_level_(on_level) {
      const uint8_t status = SREG;
      cli();
      {
        // Pullup
        volatile uint8_t* pin_ctrl_regs =  &(port.PIN0CTRL);
        pin_ctrl_regs[bit_index] |= PORT_PULLUPEN_bm;
        // Input
        port_.DIRCLR = bit_mask_;
      }
      SREG = status;
    }

    // Returns true if pin is at on level..
    inline bool is_on() {
      if (on_level_) {
        return (port_.IN & bit_mask_);
      } else {
        return !(port_.IN & bit_mask_);
      }
    }

  private:
    PORT_struct&  port_;
    const uint8_t bit_mask_;
    const bool on_level_;
};

extern DigitalInPin REMOTE_SWITCH;

int rotary_read();

// ===== Digital outputs.

class DigitalOutPin {
  public:
    // Inverted if on_level == false.
    DigitalOutPin(PORT_struct& port, uint8_t bit_index, bool on_level)
      : port_(port), bit_mask_(1 << bit_index), on_level_(on_level) {
      off();
      // Set as output.
      port_.DIRSET = bit_mask_;
    }

    inline void set(bool is_on) {
      if (is_on) {
        on();
      } else {
        off();
      }
    }

    inline void on() {
      if (on_level_) {
        port_.OUTSET = bit_mask_;
      } else {
        port_.OUTCLR = bit_mask_;
      }
    }

    inline void off() {
      if (on_level_) {
        port_.OUTCLR = bit_mask_;
      } else {
        port_.OUTSET = bit_mask_;
      }
    }

    inline void toggle() {
      port_.OUTTGL = bit_mask_;
    }

    // Returns true if is on.
    inline bool is_on() {
      if (on_level_) {
        return (port_.OUT & bit_mask_);

      } else {
        return !(port_.OUT & bit_mask_);
      }
    }

  private:
    PORT_struct&  port_;
    const uint8_t bit_mask_;
    const bool on_level_;

};

extern DigitalOutPin LED0;
extern DigitalOutPin LED1;
extern DigitalOutPin LED2;
extern DigitalOutPin LED3;


// ===== Analog inputs


class AnalogInPin {
  public:
    AnalogInPin(const uint8_t ain)  : ain_(ain) {}
    int read();
  private:
    const uint8_t ain_;
};

// Read current sense value. [0, 1023].
extern AnalogInPin CURRENT_SENSE;


// ===== Debugging

// Print to USB serial output.
void printf(const char* format, ...);

// Dump ADC0 control registers.
extern void dump_adc0_registers();

}  // namespace io


#endif // IO__H

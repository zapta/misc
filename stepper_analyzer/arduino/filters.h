#ifndef FILTERS_H
#define FILTERS_H

#include <arduino.h>

// Simulates a first order RC low pass filter.
class LowPassFilter {
  public:
    // k is in the range (0.0. 1.0] with higher value having higher 
    // cutoff frequency. 
    LowPassFilter(float k, float initial_value)
      :  _k1(min(1.0, max(0.0, k))), _k2(1.0 - _k1), _value(initial_value) {
    }
    inline float value() const {
      return _value;
    }
    inline float update(float v) {
      _value = (v * _k1) + (_value * _k2);
      return _value;
    }
  private:
    // _k1 in [0.0, 1.0]
    const float _k1;
    // _k2 = 1 - _k1
    const float _k2;
    // Current filtered value.
    float _value;
};

#endif

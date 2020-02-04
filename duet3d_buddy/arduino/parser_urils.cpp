// Implementation of parser_utils.h

#include "parser_utils.h"
#include <stdlib.h>
#include <string.h>


// Try to get an unsigned integer value from a string.
// Return true if ok. If false, rstl is left as is.
bool StringToUnsignedInt(const char s[], unsigned int* rslt) {
  if (s[0] == 0) return false;  // empty string
  char* endptr;
  unsigned int temp;
  temp = (unsigned int)strtoul(s, &endptr, 10);
  if (*endptr) {
    return false;
  }
  *rslt = temp;
  return true;
}

// Try to get a floating point value from a string. if it is actually a floating
// point value, round it.
// Return true if ok. If false, rstl is left as is.
bool StringToFloat(const char s[], float* rslt) {
  if (s[0] == 0) return false;  // empty string

  // GNU strtod is buggy, it's very slow for some long inputs, and some versions
  // have a buffer overflow bug. We presume strtof may be buggy too. Tame it by
  // rejecting any strings that much longer than we expect to receive.
  if (strlen(s) > 10) return false;

  char* endptr;
  float temp;
  temp = strtof(s, &endptr);
  if (*endptr) {
    return false;
  }
  *rslt = temp;
  return true;
}

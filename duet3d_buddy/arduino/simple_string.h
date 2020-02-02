// A string with fixed buffer.
//
// A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Library/Vector.hpp

#ifndef SIMPLE_STRING_H_
#define SIMPLE_STRING_H_

#include "simple_vector.h"
#include <string.h>

// String class. This is like the vector class except that we always keep a null
// terminator so that we can call c_str() on it.
template <int N>
class SimpleString : public SimpleVector < char, N + 1 > {
  public:
    SimpleString() : SimpleVector < char, N + 1 > () {
      this->clear();
    }

    SimpleString(const char* s) : SimpleVector < char, N + 1 > () {
      this->clear();
      this->copy(s);
    }

    // Redefine 'capacity' so as to make room for a null terminator
    constexpr int capacity() const {
      return N;
    }

    // Redefine 'full' so as to make room for a null terminator
    bool full() const {
      return this->filled == N;
    }

    // Redefine base 'add' to add a null terminator
    bool add(char x);

    // Redefine base 'add' to add a null terminator
    bool add(const char* p, int n);

    bool add(const char* p) {
      add(p, strlen(p));
    }

    // Redefine 'erase' to preserve the null terminator
    void erase(int pos, int count = 1) {
      this->SimpleVector < char, N + 1 >::erase(pos, count);
      this->storage[this->filled] = '\0';
    }

    // Redefine 'truncate' to preserve the null terminator
    void truncate(int pos) {
      this->SimpleVector < char, N + 1 >::truncate(pos);
      this->storage[this->filled] = '\0';
    }

    const char* c_str() const {
      return this->storage;
    }

    void clear() {
      this->filled = 0;
      this->storage[0] = '\0';
    }

    void cat(const char* s) {
      while (*s != '\0' && this->filled < N) {
        this->storage[this->filled++] = *s++;
      }
      this->storage[this->filled] = '\0';
    }

    void copy(const char* s) {
      this->clear();
      this->cat(s);
    }

    template <int M>
    void copy(SimpleString<M> s) {
      copy(s.c_str());
    }

    // Compare with a C string. If the C string is too long but the part of it we
    // could accommodate matches, return true.
    bool similar(const char* s) const {
      return strncmp(s, this->storage, N) == 0;
    }

    // Compare with a C string
    bool equals(const char* s) const {
      return strcmp(s, this->storage) == 0;
    }

    bool equalsIgnoreCase(const char* s) const {
      return strcasecmp(s, this->storage) == 0;
    }
};

// Redefine 'add' to add a null terminator
template <int N>
bool SimpleString<N>::add(char x) {
  this->SimpleVector < char, N + 1 >::add(x);
  const bool overflow = (this->filled == N + 1);
  if (overflow) {
    --this->filled;
  }
  this->storage[this->filled] = '\0';
  return !overflow;
}

// Redefine 'add' to add a null terminator
template <int N>
bool SimpleString<N>::add(const char* p, int n) {
  this->SimpleVector < char, N + 1 >::add(p, n);
  const bool overflow = (this->filled == N + 1);
  if (overflow) {
    --this->filled;
  }
  this->storage[this->filled] = '\0';
  return !overflow;
}

#endif /* SIMPLE_STRING_H_ */

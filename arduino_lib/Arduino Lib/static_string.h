// A basic string class that uses a fix static buffer allocation.
//
// Typicall usage:
//   static StaticString<30> string1;
//   static StaticString<60> string2;
//
// Avoid using for auto variables since it will reserve the 
// buffer space on the stack and may cause a stack overflow.

// TODO: add convience operators such as ==, !=, [].

#ifndef STATIC_STRING_H_
#define STATIC_STRING_H_

// A string class with an internal buffer of a fixed capacity.
// N is the max number of chars it can contain, in addition to the
// null terminator.
template <int N>
class StaticString {
 public:
  StaticString() { clear(); }

  // Remove all the chars currently in this string.
  void clear() {
    size_ = 0;
    terminate();
  }

  // Returns a pointer to the chars currently in this string.
  // The chars are followed by a null char. Returned pointer
  // is good for the lifetime of this string and will
  // reflect string mutations. During execution of methods
  // of this string, the content may be undefined.
  const char* c_str() { return storage_; }

  // Return the number of chars currently in this string.
  int size() const { return size_; }

  // Returns the max number of chars that this string can
  // contain.
  constexpr int capacity() const { return N; }

  // Returns the number of chars that can be added to this
  // string without truncation.
  int available() const { return N - size_; }

  // Returns true if this string is empty.
  bool is_empty() const { return size_ == 0; }

  // Returns true if this string is full to capacity.
  bool is_full() const { return size_ == N; }

  bool trim(int n) {
    if (n < 0 || n > size_) {
      return false;
    }
    // For simplicity, we update also if n == size_.
    size_ = n;
    terminate();
    return true;
  }

  // Append the char to this string if fits. Returns
  // true if added.
  bool add(char x) {
    if (is_full()) {
      return false;
    }
    storage_[size_++] = x;
    terminate();
    return true;
  }

  // Append n chars to this string. Truncate if needed to avoid
  // overflow. Returns tru if fit without truncation. Does not have
  // special treatment for null characters in s.
  bool add(const char* s, int n) {
    const bool overflow = available() < n;
    const int n1 = overflow ? available() : n;
    const int target_size = size_ + n1;
    while (size_ < target_size) {
      storage_[size_++] = *s++;
    }
    if (n1) {
      terminate();
    }
    return !overflow;
  }

  // Append the string s to the content fo this string.
  // Truncate if needed to avoid overflow. Returns true
  // if fit without truncation.
  bool add(const char* s) {
    const char* const s0 = s;
    while (*s) {
      if (is_full()) {
        if (s != s0) {
          terminate();
        }
        return false;
      }
      storage_[size_++] = *s++;
    }
    if (s != s0) {
      terminate();
    }
    return true;
  }

  // Replaces the content of this string with s. Truncates
  // if needed to avoid overflow. Returns true if fit without
  // truncation.
  bool copy(const char* s) {
    clear();
    return add(s);
  }

  // Returns true if this string equals to s (case sensitive).
  bool equals(const char* s) {
    const int n = strlen(s);
    if (n != size_) {
      return false;
    }
    return memcmp(storage_, s, n) == 0; 
  }

  // Returns true if this strings starts with s (case sensitive).
  bool starts_with(const char* s) {
    const int n = strlen(s);
    if (n > size_) {
      return false;
    }
    return memcmp(s, storage_, n) == 0;
  }

  bool ends_with(const char* s) {
    const int n = strlen(s);
    if (n > size_) {
      return false;
    }
    const int offset = size_ - n;
    return memcmp(s, storage_ + offset, n) == 0;
  }

 private:
  // Write the null terminator. Assuming size_ is valid.
  void terminate() { storage_[size_] = '\0'; }

  char storage_[N + 1];  // static buffer
  int size_;             // size
};

#endif /* SIMPLE_STRING_H_ */

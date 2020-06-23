// A vector with fixed buffer.
//
// A slimmed down version of
// https://github.com/dc42/PanelDueFirmware/blob/master/src/Library/Vector.hpp

#ifndef SIMPLE_VECTOR_H_
#define SIMPLE_VECTOR_H_

// Bounded vector class
template <class T, int N>
class SimpleVector {
  public:
    SimpleVector() : filled(0) {}

    bool full() const {
      return filled == N;
    }

    constexpr int capacity() const {
      return N;
    }

    int size() const {
      return filled;
    }

    bool isEmpty() const {
      return filled == 0;
    }

    const T& operator[](int index) const {
      return storage[index];
    }

    T& operator[](int index) {
      return storage[index];
    }

    bool add(const T& x);

    bool add(const T* p, int n);

    void erase(int pos, int count = 1);

    void truncate(int pos);

    void clear() {
      filled = 0;
    }

    const T* c_ptr() {
      return storage;
    }

    // void sort(bool (*sortfunc)(T, T));

    bool replace(T oldVal, T newVal);

  protected:
    T storage[N];  // static buffer
    int filled;    // size
};

template <class T, int N>
bool SimpleVector<T, N>::add(const T& x) {
  if (filled < N) {
    storage[filled++] = x;
    return true;
  }
  return false;
}

template <class T, int N>
bool SimpleVector<T, N>::add(const T* p, int n) {
  while (n != 0) {
    if (filled == N) {
      return false;
    }
    storage[filled++] = *p++;
    --n;
  }
  return true;
}

template <class T, int N>
void SimpleVector<T, N>::erase(int pos, int count) {
  while (pos + count < filled) {
    storage[pos] = storage[pos + count];
    ++pos;
  }
  if (pos < filled) {
    filled = pos;
  }
}

template <class T, int N>
void SimpleVector<T, N>::truncate(int pos) {
  if (pos < filled) {
    filled = pos;
  }
}

template <class T, int N>
bool SimpleVector<T, N>::replace(T oldVal, T newVal) {
  for (int i = 0; i < filled; ++i) {
    if (storage[i] == oldVal) {
      storage[i] = newVal;
      return true;
    }
  }
  return false;
}

#endif /* SIMPLE_VECTOR_H_ */

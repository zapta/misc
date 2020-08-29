// Arduino Lib.cpp : This file contains the 'main' function. Program execution
// begins and ends there.
//

#include <stdio.h>

#include <iostream>

#include "static_string.h"

StaticString<10> s;

static void dump_attr() {
  printf("size=%d, capacity=%d, margin=%d, is_full=%d, is_empty=%d, value=[%s]",
         s.size(), s.capacity(), s.available(), s.is_full(), s.is_empty(),
         s.c_str());
}

static void dump(const char* description, bool value) {
  printf("\n%s:\n  returned: %d\n  state: ", description, value);
  dump_attr();
  printf("\n\n");
}

int main() {
  printf("----- GROUP 1\n");
  dump("add char", s.add('x'));
  dump("add char", s.add('y'));
  dump("empty add", s.add(""));
  dump("fill margin", s.add("12345678"));
  dump("add char", s.add('z'));
  dump("add_str", s.add("aaa"));
  s.clear();
  dump("clear", true);

  printf("----- GROUP 2\n");
  dump("add with overflow", s.add("abcdefghijkl"));
  dump("copy", s.copy("1234"));
  dump("copy with overflow", s.copy("1234567890abcdef"));
  dump("empty copy", s.copy(""));
  s.clear();
  dump("clear", true);

  printf("----- GROUP 3\n");
  dump("add str", s.add("abcdef"));
  dump("compare match", s.equals("abcdef"));
  dump("compare no match", s.equals("abcdefe"));
  dump("compare no match", s.equals("abcde"));
  dump("compare no match", s.equals("abCdef"));

  dump("starts with", s.starts_with(""));
  dump("starts with", s.starts_with("ab"));
  dump("starts with", s.starts_with("abcdef"));
  dump("starts with (NO)", s.starts_with("abcdefg"));
  dump("starts with (NO)", s.starts_with("aBcdef"));

  dump("ends with empty", s.ends_with(""));
  dump("ends with all", s.ends_with("abcdef"));
  dump("ends with substring", s.ends_with("ef"));
  dump("ends with wrong case", s.ends_with("eF"));
  dump("ends with too much", s.ends_with("efg"));

  s.clear();
  dump("clear", true);

  printf("----- GROUP 4\n");
  dump("add str", s.add("abcdef"));
  dump("trim good", s.trim(4));
  dump("trim same size", s.trim(4));
  dump("trim negative", s.trim(-1));
  dump("trim over size", s.trim(5));
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started:
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add
//   Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project
//   and select the .sln file

#ifndef HEADER_ONLY_H_
#define HEADER_ONLY_H_

#include <iostream>

class HeaderOnlyClass {
 public:
  void Process() {
    int c = 0;
    std::cout << "HeaderOnlyClass instance is processing" << std::endl;
  }
};

#endif  // HEADER_ONLY_H_

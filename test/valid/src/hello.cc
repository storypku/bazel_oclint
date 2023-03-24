#include <iostream>
#include "foo.h"

namespace {
void UnusedFunction() {
  std::cout << "This function is meant to be unused." << std::endl;
}
} // namespace

int main(int argc, char *argv[]) {
  std::cout << "Hello world" << std::endl;
  std::cout << "The result of Foo() is: " << Foo() << std::endl;
  return 0;
}

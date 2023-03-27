#include <iostream>

namespace {

struct Foo {
  void DoSomething() { std::cout << "Foo::DoSomething() called\n"; }
};

}  // namespace
int main() {
  std::cout << "Hello world\n";
  int c = 0;

  Foo* pfoo = nullptr;
  pfoo->DoSomething();
  return 0;
}

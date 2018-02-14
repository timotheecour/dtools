#include <stdio.h>
#include <string>

template<typename T>
struct Darray{
  size_t length;
  T* ptr;
  Darray(size_t length, T* ptr):length(length),ptr(ptr){}
};
typedef Darray<char> Dstring;

void d_initialize();

Dstring funLib(Dstring input);

void dump(Dstring input){
  printf("%.*s\n", (int)input.length, input.ptr);
}

int main (int argc, char *argv[]) {
  d_initialize();
  char a[] = "hello world";
  Dstring a2{strlen(a), a};
  dump(a2);
  auto a3=funLib(a2);
  dump(a3);
  return 0;
}

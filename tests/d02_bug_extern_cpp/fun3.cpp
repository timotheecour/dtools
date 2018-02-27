#include <stdio.h>

class A{
public:
  int x;
  /*
  key method; must be virtual and defined in C++
  https://dlang.slack.com/archives/D8Q3TFKCH/p1518815290000586
  */
  virtual ~A();
  A(){x=13;}
};

void initialize(A*a, int x);

A::~A(){
}

int main (int argc, char *argv[]) {

  auto a=new A();
  initialize(a, 100);
  printf("x2:%d\n", a->x);
  printf("a2=%p\n", (void*)a);
  printf("ax2=%p\n", (void*)(&a->x));

  return 0;
}

import core.stdc.stdio;

extern(C++) class A{
public:
  int x;
  ~this();
  @disable this();
}

extern(C++)
void initialize(A a, int x){
  a.x=x;
  printf("x=%d\n", a.x);
  printf("a=%p\n", cast(void*)a);
  printf("ax=%p\n", cast(void*)(&a.x));
}

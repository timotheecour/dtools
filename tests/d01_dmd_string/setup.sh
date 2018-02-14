set -u

build(){
  dmd_lib_D=$homebrew_D/Cellar/dmd/2.078.1/lib
  dmd -of=libfun.a -lib fun.d
  clang++ -o main -std=c++11 -Wl,-L.,-L$dmd_lib_D,-lphobos2,-lfun,-no_compact_unwind main.cpp
  ./main
  rm ./main libfun.a
}

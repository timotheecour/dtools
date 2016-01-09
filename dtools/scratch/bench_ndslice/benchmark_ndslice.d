/+
$ldc_X -O3 -inline -release -boundscheck=off -mcpu=native -L-L=$dmd_build_D -I=$phobos_D benchmark_ndslice.d -of=/tmp/benchmark_ndslice

/tmp/benchmark_ndslice 100 101 100000000 1 true m2d m2c
2029600000000
5 ms, 290 μs, and 2 hnsecs
2029600000000
743 ms and 491 μs
+/

module benchmark_ndslice;

import std.stdio;//TODO:remove?
import std.experimental.ndslice;
import std.algorithm:sum;

auto get_tensor(uint n0, uint n1){
  import std.range:iota;
  int m=2;
  import std.array:array;
  auto a=iota(n0*n1*m)
  .sliced(n0, n1, m);
  return a;
}

struct Param{
  int t;
  bool transposed;
}

auto fun(T)(T c, const ref Param param){
  auto cs=c.shape;
  return cs[0]+cs[1]*2+cs[2]*3+c.byElement[$-param.t];
}

auto test(string mode)(uint n0, uint n1, size_t iter, const Param param){
  auto a=get_tensor(n0,n1);
  size_t b;
  foreach(i;0..iter){
    static if(false){}

    else static if(mode=="m2c"){
      auto c=a;
      if(param.transposed) c=c.transposed!(1,0);
      if(param.t) c=c[param.t..$-param.t, param.t..$-param.t];
      b+=c.fun(param);
    }

    else static if(mode=="m2d"){
      //NOTE: in real life, would would precompute a (fixed) indexing operator r=fun(param, a.shape), and then have: auto c=a.opIndex(r);
      auto c=a
      .transposed!(1,0)
      [param.t..$-param.t, param.t..$-param.t]
      ;
      b+=c.fun(param);
    }

    else{
      static assert(0, mode);
    }
  }
  return b;
}

void main(string[]args){
  Param param;
  import std.conv:to;
  import std.exception;
  enforce(args.length==8, args.to!string);
  int i=1;
  auto n0=args[i++].to!uint;
  auto n1=args[i++].to!uint;
  auto n=args[i++].to!size_t;
  param.t=args[i++].to!int;
  param.transposed=args[i++].to!bool;

  string mode;

  void testfun(){
    size_t ret;
    import std.typetuple;
    foreach(mode2;TypeTuple!("m2c", "m2d")){
      if(mode2==mode){
          ret+=test!mode2(n0, n1, n, param);
        ret.writeln;
        return;
      }
    }
    enforce(0);
  }

  import std.datetime;
  foreach(j;0..2){
    mode=args[i++];
    benchmark!testfun(1)[0].to!Duration.writeln;
  }
}

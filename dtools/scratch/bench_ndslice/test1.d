module tests.ndslice.test1;

/+
$ldc_X -O3 -inline -release -boundscheck=off -mcpu=native -L-L=$dmd_build_D -I=$phobos_D $code/tests/ndslice/test1.d -of=/tmp/benchmark_ndslice
/tmp/benchmark_ndslice 100
4 secs, 715 ms, 212 μs, and 8 hnsecs
2 secs, 485 ms, 110 μs, and 4 hnsecs

=> input.cat.reallocate.rest_of_pipeline 
can be slower than
=> input.cat.rest_of_pipeline
+/

import std.experimental.ndslice;
import std.range;
import std.stdio;
import std.algorithm;
import std.conv;

struct Param{
  uint iter;
  size_t n0=1000;
  size_t n1=2000;
  size_t border=100;
}

import std.experimental.ndslice.internal:Iota;

auto  cat(T...)(T a){
  auto shape=a[0].shape;
  foreach(i;Iota!(1, T.length)){
    shape[0]+=a[i].shape[0];
    assert(shape[1..$]==a[i].shape[1..$]);
  }
  return chain(a[0].byElement, a[1].byElement, a[2].byElement).sliced(shape);//TODO:more generic
}

auto reallocate(S)(S a) //if (isSlice!S)
{
  return a.byElement.array.sliced(a.shape);
}

size_t result;

void test2(alias fun)(Param param){
  auto n0=param.n0;
  auto n1=param.n1;
  auto border=param.border;
  auto image=iota(n0*n1).sliced(n0,n1);
  auto border0=image[0..border, 0..$].reversed!0;
  auto border1=image[$-border..$, 0..$].reversed!0;
  auto padded_image=cat(border0, image, border1);

  int counter=0;

  auto c=fun(padded_image)

  [1..$-1, 1..$-1]
  .transposed
  .byElement.reduce!( (a,b) => a+(counter++)*b);

  result+=c;
}

void parseFrom(T)(ref T a, string b){
  a=b.to!T;
}

void main(string[]args){
  Param param;

  int i=1;
  assert(args.length==2);
  param.iter.parseFrom(args[i++]);
 
  import std.datetime;
  import std.conv:to;

  benchmark!(
  { test2!reallocate(param); },
  { test2!(a=>a)(param); },
  )
  (param.iter)[].to!(Duration[]).each!writeln;

  writeln(result);
}
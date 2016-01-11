module tests.ndslice.test1;

/+
$ldc_X -O3 -inline -release -boundscheck=off -mcpu=native -L-L=$dmd_build_D -I=$phobos_D $code/tests/ndslice/test1.d -of=/tmp/benchmark_ndslice
/tmp/benchmark_ndslice 50
1418
1036

=> input.cat.reallocate.rest_of_pipeline 
can be slower than
=> input.cat.rest_of_pipeline
+/

import std.experimental.ndslice;
import std.range;
import std.stdio;
import std.algorithm;
import std.conv;

struct Param {
  uint iter;
  size_t n0 = 1000;
  size_t n1 = 2000;
  size_t border = 20;
}

import std.experimental.ndslice.internal : Iota;

auto cat(T...)(T a) {
  auto shape = a[0].shape;
  foreach (i; Iota!(1, T.length)) {
    shape[0] += a[i].shape[0];
    assert(shape[1 .. $] == a[i].shape[1 .. $]);
  }
  return chain(a[0].byElement, a[1].byElement, a[2].byElement).sliced(shape); //TODO:more generic
}

auto reallocate(S)(S a) //if (isSlice!S)
{
  return a.byElement.array.sliced(a.shape);
}

size_t result;

void compute_integral_image(T, T2)(T image, T2 II0) {
  auto p = image.shape[1];
  auto q = image.shape[0];
  int i, j;
  int k = 0;
  alias U = typeof(image.byElement.front);
  U temp;

  auto rowsums = new U[p];
  rowsums[] = 0;

  assert(image.elementsCount == p * q);
  assert(II0.elementsCount == p * q);
  auto pimage = image.byElement;
  auto pII0 = II0.byElement;
  for (j = 0; j < q; j++) {
    temp = 0;
    for (i = 0; i < p; i++, k++) {
      pII0.front = cast(int)(temp += (rowsums[i] += pimage.front));
      pimage.popFront;
      pII0.popFront;
    }
  }
}

auto pad(T)(T image, size_t border) {
  auto border0 = image[0 .. border, 0 .. $].reversed!0;
  auto border1 = image[$ - border .. $, 0 .. $].reversed!0;
  auto padded_image = cat(border0, image, border1);
  return padded_image;
}

int[] II_arr;

void test2(alias fun, I)(I image, Param param) {
  auto n0 = param.n0;
  auto n1 = param.n1;
  auto padded_image = pad(image, param.border);

  int counter = 0;

  auto c = fun(padded_image);
  II_arr.assumeSafeAppend;
  //TODO:make sure no alloc after 1st one
  II_arr.length = c.elementsCount;
  auto II0 = II_arr.sliced(c.shape);
  compute_integral_image(c, II0);

  result += II_arr[$ - 1];
}

void parseFrom(T)(ref T a, string b) {
  a = b.to!T;
}

void main(string[] args) {
  Param param;

  int i = 1;
  assert(args.length == 2);
  param.iter.parseFrom(args[i++]);

  import std.datetime;
  import std.conv : to;

  auto n0 = param.n0;
  auto n1 = param.n1;

  auto image = iota(n0 * n1).array.sliced(n0, n1)[1 .. $, 1 .. $];

  benchmark!({ test2!reallocate(image, param); }, { test2!(a => a)(image, param); },)(param.iter)[].to!(Duration[]).map!(a => a.total!"msecs").each!writeln;

  writeln(result);
}

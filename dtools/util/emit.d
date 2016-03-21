module dtools.util.emit;

/+
$emit generalizes $map, $filter, $joiner

given fun(put, a) a function that can call $put 0 or more timesm
range.emit!fun computes a range formed of all the calls to $put

eg:
assert(9.iota.emit!(int,(put,a){if(a%2) put(a*a);}).equal([1, 9, 25, 49]));
+/

// TODO:can we infer T?
template emit(T, alias fun) {
  auto emit(Range)(Range r) if (isInputRange!(Unqual!Range)) {
    // TODO:static assert on types
    return EmitResult!(fun, Range, T)(r);
  }
}

import std.traits : isIterable, isNarrowString;
import std.range : isInfinite, hasLength,isInputRange;
import std.traits : ForeachType,Unqual;

unittest {
  import std.range : iota, chain;
  import std.conv : text, to;
  import std.array;
  auto input=chain(iota(0, 3), iota(4, 7));
  auto temp = input.emit!(string, (put, a) { put(text("i:", a)); if (a % 2) put(text("o:", a)); });

  import std.algorithm : equal;
  assert(equal(temp, ["i:0", "i:1", "o:1", "i:2", "i:4", "i:5", "o:5", "i:6"]));

  auto temp3=9.iota.emit!(int,(put,a){if(a%2) put(a*a);});
  assert(equal(temp3, [1, 9, 25, 49]));
  // equivalent with fitler/map
  import std.algorithm:filter,map,each;
  assert(equal(iota(9).filter!(a=>a%2).map!(a=>a*a), [1, 9, 25, 49]));

  auto temp4=5.iota.emit!(int,(put,a){a.iota.each!((b){put(b);});});
  assert(equal(temp4, [0, 0, 1, 0, 1, 2, 0, 1, 2, 3]));
  // no simple efficient equivalent with map/filter/joiner since joiner will allocate in each group

  //BUG:D20160321T034620
  // TODO: why do i get: $code/util/emit.d(38,14): Error: cannot resolve type for temp.array(Range)(Range r) if (isIterable!Range && !isNarrowString!Range && !isInfinite!Range)
  //static assert(is(typeof(temp.array)));
  alias Range = typeof(temp);
  static assert(isInputRange!Range);
  static assert(isIterable!Range && !isNarrowString!Range && !isInfinite!Range);

  static assert(is(typeof(temp.array2)));
}

private struct EmitResult(alias emitter, Range, T) {
  import std.range : isForwardRange;

  private {
    alias R = Unqual!Range;
    R _input;
    import std.array;

    //alias Q=Appender!(E[]);
    alias Q = T[];
    // TODO:assumeUnique needed?
    Q q;
    size_t index;
  }

  this(R r, Q q2 = Q.init, size_t index2 = 0) {
    _input = r;
    q = q2;
    index = index2;
    // TODO:why does FilterResult call pred in constructor eagerly? (doing same here...)
    popFrontAux;
  }

  auto opSlice() {
    return this;
  }

  static if (isInfinite!Range) {
    enum bool empty = false;
  }
  else {
    @property bool empty() {
      return index == q.length;
    }
  }

  void popFront() {
    assert(index < q.length);
    index++;
    if (index == q.length) {
      index = 0;
      //TODO:will it clear? we don't want to (to reuse buffer)
      q.length = 0;
      popFrontAux;
    }
  }

  @property auto ref front() {
    return q[index];
  }

  static if (isForwardRange!R) {
    @property auto save() {
      //TODO:is .dup needed?
      return typeof(this)(_input.save, q.dup, index);
    }
  }

private:
  void add(T a) {
    q ~= a;
  }

  void popFrontAux() {
    while (!_input.empty) {
      emitter(&add, _input.front);
      _input.popFront();
      if (!q.length == 0)
        break;
    }
  }
}

// NOTE: copied from std.array.array because of D20160321T034620
ForeachType!Range[] array2(Range)(Range r) if (isIterable!Range && !isNarrowString!Range && !isInfinite!Range) {
  if (__ctfe) {
    // Compile-time version to avoid memcpy calls.
    // Also used to infer attributes of array().
    typeof(return) result;
    foreach (e; r)
      result ~= e;
    return result;
  }

  alias E = ForeachType!Range;
  static if (hasLength!Range) {
    auto length = r.length;
    if (length == 0)
      return null;

    import std.conv : emplaceRef;

    auto result = (() @trusted => uninitializedArray!(Unqual!E[])(length))();

    // Every element of the uninitialized array must be initialized
    size_t i;
    foreach (e; r) {
      emplaceRef!E(result[i], e);
      ++i;
    }
    return (() @trusted => cast(E[]) result)();
  }
  else {
    import std.array : appender;

    auto a = appender!(E[])();
    foreach (e; r) {
      a.put(e);
    }
    return a.data;
  }
}

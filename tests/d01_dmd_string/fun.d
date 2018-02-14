/+
https://github.com/dlang/dmd/pull/7870#discussion_r168174068
proposal:
use Dstring instead of char* in dmd compiler sources for extern(C++) apis.
eg: `extern (C++) int fp(void* param, const(char)* str)`

advantages:
* no loss of length informtion
* easier to convert back and forth from char[] to char*
+/

import std.conv:to;

extern(C++)
struct Darray(T){
  size_t length;
  T* ptr;

  extern(D) this(T[]a){
    this.length=a.length;
    this.ptr=a.ptr;
  }

  extern(D) T[] toNative() {
    // TODO: could even use a raw cast since ABI is same
    return ptr[0..length];
  }

  /+
  TODO:DMD:BUG?
  why not picked up by input.to!(char[]) ?
  extern(D) T2 opCast(T2)() if(is(T2==T[])) {
    return ptr[0..length];
  }
  +/
}

version (dmd_native_string){
  // eg:DigitalMars
  alias Dstring=char[];
  // TODO: toNative and fromNative
} else {
  alias Dstring=Darray!char;
}

extern(C++) void d_initialize(){
  import core.runtime;
  Runtime.initialize;
}

extern(C++) Dstring funLib(Dstring input){
  import std.string:toUpper;
  return input.toNative.toUpper.to!Dstring;
}

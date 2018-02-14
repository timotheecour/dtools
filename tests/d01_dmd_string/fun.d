/+
https://github.com/dlang/dmd/pull/7870#discussion_r168174068

better yet: for all the apis used by ldc, gdc:

use a compiler dependent (via eg version(LDC)) type Dstring, which for dmd is alias to char[] and for ldc, dmd is alias to extern(C++) struct with size and char* head, along with conversions functions.
that way, dmd code stays clean, safe and keeps length aroud


better yet: for all the apis used by ldc, gdc
use a compiler dependent (via eg version(LDC)) type Dstring, which for dmd is alias to char[] and for ldc, dmd is alias to extern(C++) struct with size and char* head, along with conversions functions.
that way, dmd code stays clean, safe and keeps length aroud


// current
extern (C++) int fp(void* param, const(char)* str){
  PushAttributes* p = cast(PushAttributes*)param;
  p.mods.push(new StringExp(Loc.initial, cast(char*)str));
  return 0;
}
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
  //auto input2=input.to!(char[]); // checkme
  TODO:DMD:BUG? why not picked up by to!(char[]) ?
  +/
  version(none)
  extern(D) T2 opCast(T2)() if(is(T2==T[])) {
    return ptr[0..length];
  }
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

/+
Usage

build lldb with https://github.com/llvm-mirror/lldb/pull/3
## build
```
git clone https://github.com/llvm-mirror/llvm.git
cd llvm/tools
git clone https://github.com/llvm-mirror/lldb
## also, patch in https://github.com/llvm-mirror/lldb/pull/3
git clone https://github.com/llvm-mirror/clang
cd ..
mkdir build
cd build
cmake .. -G Ninja
ninja all
```

## run
```
DYLD_LIBRARY_PATH=$path_to_lldbplugin/ $path_to/lldb -- $some_program
b full.qualified.name
#understands D fully qualified names (note: no templates yet it seems)
r
bt
# shows backtrace with demangled D symbols
```

+/
module dtools.lldbdplugin;

import core.stdc.stdio;
import core.runtime;

extern(C) 
void d_initialize(){
  Runtime.initialize;
  //import core.memory;
  //GC.disable();
}

extern(C)
char* lldbd_demangle(size_t length, const(char)* mangled){
  import core.demangle:demangle;
  enum L_max=1024*10;
  enum L_max2=200;
  //enum L_max2=L_max;
  static bool first=true;
  static char[] dst;
  //PRTEMP
  if(first){
    first=false;
    dst = L_max.malloc2!char;
  } 
  if(length>L_max2){ //CHECKME
    return mangled[0..length].malloc_cpy(true).ptr;
  }
  auto ret = demangle(mangled[0..length], dst);
  return ret.malloc_cpy(true).ptr;
}

T[] malloc2(T)(size_t length){
  import core.stdc.stdlib:malloc;
  auto ptr=malloc(length*T.sizeof);
  assert(ptr);
  return cast(T[])ptr[0..length];
}

private:
void ensure_initialize(){
  import core.runtime;
  __gshared bool init=false;
  if(!init){
    init=true;
    Runtime.initialize;
  }
}

// IMPROVE using allocator?
auto malloc_cpy(T)(T a, bool trailing0){
  import std.traits:Unqual;
  alias T2=Unqual!(typeof(a[0]));

  auto L=a.length;
  auto L2=L + (trailing0?1:0);
  auto ret2=L2.malloc2!T2;
  ret2[0..L] = a[0..L];
  if(trailing0)
    ret2[L2-1]=0;
  return ret2;
}

unittest{
  auto mangled="_D4vibe4data4bson__T15serializeToBsonTS3std8typecons__T8NullableTS2lh11dll_for_cpp3src5proto9vizserver8__mixin313AlignPoseDataZQCuZQEhFNfQDvAhZSQFmQFkQFi4Bson";
  auto temp2=lldbd_demangle(mangled.length, mangled.ptr);
  import std.conv:text;
  import std.stdio:writeln;
  writeln(temp2.text);
}

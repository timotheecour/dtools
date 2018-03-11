/+
Usage

build lldb with https://reviews.llvm.org/D44321 (formerly https://github.com/llvm-mirror/lldb/pull/3)
```
## build lldb
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

## build lldbdplugin
#dtools_D=path to dtools repo
ldmd2 -of=liblldbdplugin.dylib -shared -g -I$dtools_D $dtools_D/dtools/modified/demangle.d $dtools_D/dtools/lldbdplugin.d
```

## run
```
## add this to .lldbinit:
settings set plugin.language.D.pluginfile "path_to/liblldbdplugin.dylib"

$path_to/lldb -- $some_program
b full.qualified.name
#understands D fully qualified names (note: no templates yet it seems)
r
bt
# shows backtrace with demangled D symbols

addresses: https://issues.dlang.org/show_bug.cgi?id=8172
```

+/
module dtools.lldbdplugin;

import core.stdc.stdio;
import core.runtime;
import core.thread;
import core.memory;
import std.concurrency;

extern(C) 
void d_initialize(){
  auto ok = Runtime.initialize;
  assert(ok);
}

extern(C) char* lldbd_demangle(size_t length, const(char)* mangled){
  import dtools.alloc;
  auto mangled2=mangled[0..length];

  // can configure
  enum L_max=size_t.max;
  if(length>=L_max)
    return mangled2.malloc_cpy(true).ptr;

  import dtools.modified.demangle:demangle;
  auto ret = demangle(mangled2);
  return ret.malloc_cpy(true).ptr;
}

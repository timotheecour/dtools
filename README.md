dtools
======

Tools for D programming language

Author: Timothee Cour

Contributors: Jacob Carlborg

Features:
-------------
1.  function calling with named parameters: 
  
  ```d
  auto a=named!fun.z(3).x(4)();
  ```

2.  (much more to come later)




Requirements:
-------------
rdmd in path with recent version of dmd

Usage:
-------------

    #1 clone repo and cd
    base_D=~/temp/git_clone
    mkdir -p $base_D 
    cd $base_D 
    git clone https://github.com/timotheecour/dtools.git 
    cd dtools 
    
    #2 run unittests
    rdmd --main -unittest dtools/util/functional.d
    rdmd --main -unittest dtools/util/log.d

    #3 try out examples
    rdmd -version=test1 dtools/examples/test1

    #build build/d_funs
    rdmd -version=is_main --build-only -odbuild/ dtools/util/d_funs

    #mixin insight on a file:
    ./build/d_funs dtools/examples/test2.d


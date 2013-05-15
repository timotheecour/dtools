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

2.  template constructor (partial) instantiation
  ```d
  auto a=make!(A,double)(1);
  // calls templated constructor with explicit instantiation.
  ```
3.  Take address of a class/struct/anything reliably regardless of opCast defined in class:
  ```d
  class A{}
  A a;
  auto a2=a;
  assert(AddressOf(a) == AddressOf(a2) );
  ```

4.  mixin insight on a file (experimental)

5.  (much more to come later)




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
    export dtools_D=`pwd`/
    
    #2 run unittests
    rdmd --main -unittest -I${dtools_D} ${dtools_D}dtools/util/_.d

    #3 try out examples
    rdmd -version=test1 ${dtools_D}dtools/examples/test1

    #build build/d_funs
    rdmd -version=is_main --build-only -od${dtools_D}build/ ${dtools_D}dtools/util/d_funs

    #mixin insight on a file:
    ${dtools_D}build/d_funs ${dtools_D}dtools/examples/test2.d

    #monod plugin (experimental)    
    rdmd --build-only -g -version=simple -I${dtools_D} -of${dtools_D}build/ ${dtools_D}dtools/temp/monod_plugin_1.d
    ${dtools_D}build/monod_plugin_1 -index_begin=18 -index_end=200 -file=${dtools_D}dtools/temp/monod_plugin_1.d -operation=toUpper

    #or all at the same time:
    rdmd -g -version=simple -I${dtools_D} ${dtools_D}dtools/temp/monod_plugin_1.d -index_begin=18 -index_end=200 -file=${dtools_D}dtools/temp/monod_plugin_1.d -operation=toUpper



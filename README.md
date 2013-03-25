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



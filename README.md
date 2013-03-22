dtools
======

Tools for D programming language

Author: Timothee Cour

Description:

function calling with named parameters with syntax: 
auto s=callNamed!(fun,`x,y`)(10,20);
(much more to come later)


Requirements:
rdmd in path with recent version of dmd

Example usage:

#1 clone repo and cd
base_D=~/temp/git_clone
mkdir -p $base_D 
cd $base_D 
git clone https://github.com/timotheecour/dtools.git 
cd dtools 

#2 test functionality
rdmd --main -unittest dtools/util/functional.d



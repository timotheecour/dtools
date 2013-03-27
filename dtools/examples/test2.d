/+
 rdmd dtools/examples/test2.d
 rdmd -version=is_main dtools/util/d_funs dtools/examples/test2.d
 +/
module dtools.examples.test2;
import std.stdio;


void main(){
	test;
}

import std.array;
import std.range;
import std.algorithm;

void test(){
	enum a="as df".split(" ").map!(a=>a~"!"~a).join("_");
	{	auto x1=mixin(`"1"~a~"2"~a~"3"`);	writeln(x1);}
	{	auto x1=mixin(`a`); writeln(x1);	}
	{	auto x1=mixin(`1+10`); writeln(x1);	}
	{	auto x1=mixin(`a.length`);	writeln(x1);}

}

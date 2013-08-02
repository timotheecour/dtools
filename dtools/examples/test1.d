/+
rdmd -version=test1 dtools/examples/test1
+/
module dtools.examples.test1;

import std.stdio;


void main(){
	test;
}

version(test1){
}
else
version(test2){

	import std.array;
	import std.range;
	import std.algorithm;
	import dtools.util.d_funs;

	void test(){
		enum a="as df".split(" ").map!(a=>a~"!"~a).join("_");
		{	auto x1=mixin(`"1"~a~"2"~a~"3"`);	}
		{	auto x1=mixin(`a`);	}
		{	auto x1=mixin(`1+10`);	}
		{	auto x1=mixin(`a.length`);	}

	}

}
else
	void test(){
		assert(0);
	}



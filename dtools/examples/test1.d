/+
rdmd -version=test1 dtools/examples/test1
+/
module dtools.examples.test1;

import std.stdio;


void main(){
	test;
}


version(test1){
	import dtools.util.log;

	void test(){
		double x=1.1;
		auto s="abc";
		mixin("x*2=$(x*2), string=$s...".parse).writeln; //s1="x=1.1, string=abc"
		format("x*2=%s, string=%s...",x*2,s).writeln;
		
		version(none){
			string sa=mixin("@(x*2), @s...".parse); //s1="x=1.1, string=abc"
			string sc=mixin(prettyPrint(q{x*2,s}));
			string sc=mixin(prettyPrint(x*2,s));
			
			string sc=prettyPrint(x*2,s);
			
			version(none) //could be this simple with @mixin construct
				string sc=prettyPrint(x*2,s);
			
			//example from std.datetime:
			string s1a=mixin(`_assertPred!"$op" failed: [$lhs] is not %op [%rhs].`.parse);
			string s1b=format(`_assertPred!"%s" failed: [%s] is not %s [%s].`, op, lhs, op, rhs);
			
			//example from std.net.isemail
			string s2a=mixin("EmailStatus\n{\n\tvalid: $valid\n\tlocalPart: $localPart\n\tdomainPart: $domainPart\n\tstatusCode: $statusCode\n}".parse);
			string s2b=format("EmailStatus\n{\n\tvalid: %s\n\tlocalPart: %s\n\tdomainPart: %s\n\tstatusCode: %s\n}", valid,localPart, domainPart, statusCode);
		}
	}
}

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




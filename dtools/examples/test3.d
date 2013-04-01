/+
 rdmd dtools/examples/test3.d
 rdmd -version=is_main dtools/util/d_funs dtools/examples/test2.d
 +/
module dtools.examples.test3;
import dtools.util.log;
import std.stdio;

void main(){
	test;
}

void test(){
	double x=1.2;
	string s=parse2(x);
	writeln(s);
}

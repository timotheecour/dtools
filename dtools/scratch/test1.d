/+
usage:
ldc2 -release -O2 -run dtools/scratch/test1.d

expected output:
reltime=20.7386(%); time(base)=2333 time(t2)=2817
reltime=20.8055(%); time(base)=2334 time(t2)=2820
-1670913744

+/
module dtools.scratch.test1;

import std.conv;
import std.datetime;
import std.stdio;

void dispBenchmark(T)(T t1, T t2){
	auto t=t1.length.to!real;
	auto r=(t2.length.to!real-t)/t;
	writefln(`reltime=%s(%%); time(base)=%s time(t2)=%s`,r*100, t1.to!("msecs",int), t2.to!("msecs",int));
}

int funb(int x, int i){
	return (x+1)*(x-1);
}
ref int foo(bool checkbounds)(ref int x, int*ptr){
	foreach(i;0..8)
		x+=funb(x-i,i*x)+funb(x+i,i*x);

	static if(checkbounds){ // bounds checking (attempt for having safe references)
		if(&x>ptr){
			assert(0);
		}
	}
	return x;
}

static int x=0;

void fun(bool checkbounds)(){
	int _temp;
	x+=foo!checkbounds(x,&_temp);
}

void test(){
	enum n=100_000_000;
	auto b = comparingBenchmark!(fun!false, fun!true,n);
	dispBenchmark(b.baseTime, b.targetTime);
	// doing the same in reversed order just to make sure there's no disadvantage of being first.
	b = comparingBenchmark!(fun!true, fun!false,n);
	dispBenchmark(b.targetTime, b.baseTime);
	writeln(x);
}
void main(){test;}

module dtools.util.util;

// template constructor (partial) instantiation.
auto make(T,T2...)(T2 a){
	auto b=T.__ctor!(T2)(a);// undocumented feature, preferable to put here in one place.
	return b;
	//NOTE: return T.__ctor!(T2)(a); directly doesn't seem to work in 2.062 (bug?)
}
version(unittest){
	struct A{this(T)(T a){};}
}
unittest{
	auto a=make!(A,double)(1);
	static assert(is(typeof(a) == A));
}

// Take address of a class/struct/anything
void*AddressOf(T)(T a) if(is(T==class)){
	return *cast(void**)& a;
}
T*AddressOf(T)(ref T a) if(!is(T==class)){
	return &a;
}

unittest{
	import std.stdio;
	import std.conv;

	class A{
		int x;
		//	T opCast(T : int)() { return 1; }
		int opCast(T:void*)() { return 1; }
		//	auto opCast(T:void*)() { return null; }
	}
	struct B{		
	}

	A a;
	assert(AddressOf(a) is null);
	a = new A;
	auto a2=a;
	assert(AddressOf(a) == AddressOf(a2) );
	B b;
	assert(AddressOf(b) !is null);
	B*b2;
	assert(AddressOf(*b2) is null);
	//	writeln(AddressOf(B.init)); //waiting for rvalue ref, DIP39
}

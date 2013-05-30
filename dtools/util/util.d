module dtools.util.util;

// template constructor (partial) instantiation.
auto make(T,T2...)(T2 a){
	// __ctor: undocumented feature, we put it here in one place.
	T b0=void;
	b0.__ctor!(T2)(a);
	return b0;
	/+
	 this compiled in dmd.2.062, but not in dmd.2.063
	 auto b=T.__ctor!(T2)(a);
	 return b;
	 //	return T.__ctor!(T2)(a); //directly doesn't seem to work in 2.062
	 +/
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

/++
 quotes a so that regex will match it
 +/
string escapeRegex(string a){
	import std.string;
	enum transTable = (){
		string[char]b;
		auto a=`[]{}()*+?|^$\.`;
		foreach(ai;a)
			b[ai]=`\`~ai;
		return b;
	}();
	return translate(a, transTable);
}
string escapeRegexReplace(string a){
	import std.string;
	enum transTable = ['$' : `$$`]; 
	return translate(a, transTable);
}

unittest{
	import std.regex;
	string a=`asdf(def[ghi]+*|)][}{)(*+?|^$\/.`;
	assert(match(a,regex(escapeRegex(a))).hit==a);
	string b=`$aa\/$ $$#@$\0$1#$@%#@%=+_)][}{)(*+?|^$\/.`;
	auto s=replace(a,regex(escapeRegex(a)),escapeRegexReplace(b));
	assert(s==b);
}


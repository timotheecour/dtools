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
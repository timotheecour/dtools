module dtools.util.util;

// template constructor (partial) instantiation.
auto make(T,T2...)(T2 a){
	auto b=T.__ctor!(T2)(a);
	return b;
}
version(unittest){
	struct A{this(T)(T a){};}
}
unittest{
	auto a=make!(A,double)(1);
	static assert(is(typeof(a) == A));
}
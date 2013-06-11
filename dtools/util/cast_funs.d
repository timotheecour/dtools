/+
LINKS:
EMAIL:The cast(signed), cast(unsigned) feature proposal

TODO:
shared const, inout shared, etc.
a.Cast!"shared const" or a.Cast!SharedConst
+/

module dtools.util.cast_funs;

template Typeof(alias a){
	alias Typeof=typeof(a);
}

auto Cast(T,S)(auto ref S a){
	return cast(T)a;
}
private enum CastTypes{Unsigned, Signed,Const,Immutable}
alias Unsigned=CastTypes.Unsigned;
alias Signed=CastTypes.Signed;
alias Const=CastTypes.Const;
alias Immutable=CastTypes.Immutable;
auto Cast(alias T,S)(auto ref S a){
	import std.traits:Unsigned2=Unsigned,Signed2=Signed;
	static if(T==CastTypes.Unsigned)
		return cast(Unsigned2!S)a;
	else static if(T==CastTypes.Signed)
		return cast(Signed2!S)a;
	else static if(T==CastTypes.Const)
		return cast(const)a;
	else static if(T==CastTypes.Immutable)
		return cast(immutable)a;
	else
		static assert(0);
}

version(unittest){
	int foo(int x){
		return x;	
	}
}
unittest{
	double c;
//	auto b1=cast(int)c.foo;//means cast(int)(c.foo), so would be CT error
	auto b2=(cast(int)c).foo;//verbose syntax: 2 nested parenthesis
	auto b3=c.Cast!int.foo;//simpler syntax

	int a=1;
	auto b=(a+a).Cast!double;	
	static assert(is(typeof(b)==double));
	static assert(is(typeof(a.Cast!Immutable)==immutable(int)));
	static assert(is(typeof(a.Cast!Const)==const(int)));
	static assert(is(typeof(0U.Cast!Signed)==int));
	static assert(is(typeof(a.Cast!Unsigned)==uint));
	static assert(is(typeof(a.Cast!Const)==const(int)));
	static assert(is(typeof((a+a).Cast!Unsigned)==uint));

	auto b5=cast(shared const)a;
	import std.stdio;
	pragma(msg,typeof(b2));
}


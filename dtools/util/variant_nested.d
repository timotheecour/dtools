/+
dynamic nested data structures (see unittest)

EMAIL:From CppNow 2013

d = {'a':1, 'b':2.2, 'c':[1,2.2,'three']}
v = int(d['c'][0])
v +=3
d['c'][2] = v

Tab d="{'a':1,'b':2.2,'c':[1,2.2,'three']}";
int v = d("c")(0);
v += 3;
d["c"][2] = v;

Tab t = "{'a':{'nest':1}}";
cout << t["a"]["nest"] << endl;
t["a"]["nest"] = 17;
+/

module dtools.util.variant_nested;

import std.stdio;
import std.variant;
import std.typecons;
import std.conv;
import std.typetuple;
//MERGE:import util.static_foreach;
template Iota(int stop) {
	static if (stop <= 0)
		alias TypeTuple!() Iota;
	else
		alias TypeTuple!(Iota!(stop-1), stop-1) Iota;
}

auto variantTupleNamed(T...)(T args){
	assert(args.length%2==0);
	alias S=T[0];
	Variant2[S]b;


	foreach(i;Iota!(args.length/2)){
		b[args[2*i]]=Variant2(Variant(args[2*i+1]));
	}
	return Variant2(b);
}

alias variantStruct=variantTupleNamed;
auto variantTuple(T...)(T args){
	Variant2[]b;
	b.length=T.length;

	foreach(i;Iota!(args.length)){
		b[i]=Variant2(Variant(args[i]));
	}
	return Variant2(b);
}

template GetType(T){
	static if(isIntegral!T){
		alias GetType=Variant2[];
		//TODO:instead, based on type RT property of the variant object and see whether it's a dynamic object
	}
	else{
		alias GetType=Variant2[T];
	}
}

import std.traits;
struct Variant2{
	Variant _a;

	this(T)(T b){
		_a=b;
	}

	auto opIndex(T...)(T index){
		alias V=GetType!T;
		return _a.get!V[index];
	}
	void opIndexAssign(U,T...)(U val,T index){
		alias V=GetType!T;
		auto temp=_a.get!V;
		temp[index]=Variant2(Variant(val));
	}

	void opIndexOpAssign(string op,U,T...)(U val,T index){
		alias V=GetType!T;
		auto temp=_a.get!V;
		auto a1=temp[index];
		import std.functional;
		alias foo=binaryFun!(`a`~op~`b`);
		temp[index] = Variant2(Variant(foo(temp[index],val)));
	}

	void opOpAssign(string op:"~",T)(T a){//NOTE: because of weak variant typing, can't distinguish bw appending scalar vs vector
//		alias V=GetType!T;
		auto temp=_a.get!(Variant2[]);
		temp~=Variant2(a);
		_a=temp;//TODO:more efficient?
	}

	//TODO:support a.foo for a["foo"]?
	//TODO:opDispatchOpAssign?
	//	auto opDispatch(string s)(){ //causes issues with __ctor?
//		if(_a.type==typeid(Variant2[string]))
//			return opIndex(s);
//		else
//			return _a.opDispatch(s);
//	}
	//TODO:opOpAssign?
	alias _a this;
}

unittest{
	struct B{float z=1.5; double[2] mu;}
	auto d=variantTupleNamed("a",1,"b","foo","c",variantTuple(1,2.2,"three"));
	d["a"]=2;
	auto v=d["c"][0].get!int;//can coerce to int
	v+=3;
	d["c"][0]="other1";//can access nested type
	d["a"]="other2";//can change type
	d["a"]=variantTuple(0.0,'e');
	d["a"]=10;
	d["a"]+=2; //read-modify-write works, unlike std.variant : 'Due to limitations in current language, read-modify-write operations op= will not work properly'
	assert(d.text==`["a":12, "b":foo, "c":[other1, 2.2, three]]`); //TODO:ideally should print as: {a:12, b:foo, b:{"other1", 2.2, "three"}, or same, w types shown

	{
		Variant2 a1=0;
		a1=variantTuple(1,"a");
		a1[0]=variantTuple("foo",1.1);
		auto a2=variantTuple(3,[1]);
		a1[1]=a2;
		a1~="foo2";
		a1~=B.init;
		assert(a1.text==`[[foo, 1.1], [3, [1]], foo2, B(1.5, [nan, nan])]`);
	}

}

/+
 NOTES:
 support for syntax:
 auto s=callNamed!(fun,`x,y`)(10,20);
 given a function:
 auto fun(int x,int y=2,double z=z_val, string z2="asdf");

 Compile time errors will occur on duplicate param names, or ones that don't exist, or ones that are not optional and not provided (eg x, above)

 TODO:
 unittests to test that certain things don't compile
 support templates
 maybe mixin or code generation with attributes to support:
 auto s=fun!`x,y`(10,20);
 +/

module dtools.util.functional;

auto callNamed(alias fun,string s,T...)(T args){
	import std.traits;
	import std.array:split;
	import std.algorithm:countUntil,canFind;
	import std.algorithm:sort,uniq,walkLength;
	import std.conv:to;
	enum namesCall=split(s,",");
	static assert(namesCall.length==T.length);

	enum names=[ParameterIdentifierTuple!fun];

	int findNotIn(T)(T a,T b){
		foreach(int i,ai;a){
			if(!canFind(b,ai))
				return i;
		}
		return -1;
	}

	enum indBad=findNotIn(namesCall,names);
	static assert(indBad==-1,"bad param: " ~ namesCall[indBad] ~ " ; valid params: " ~ to!string(names));
	static assert(walkLength(uniq(sort(namesCall)))==namesCall.length,"called params not unique: " ~ namesCall);
	string getString(){
		string ret;
		foreach(i,vali ; ParameterDefaultValueTuple!fun){
			enum index=countUntil(namesCall,names[i]);
			static if(index==-1){
				static assert(!is(vali==void),"param " ~ names[i] ~ " not optional, not given");
				ret~=vali.stringof;
			}
			else{
				ret~=`args[`~to!string(index)~`]`;
			}
			if(i<names.length-1){
				ret~=",";
			}
		}
		return ret;
	}
	enum s3=`return fun(`~getString()~`);`;
	mixin(s3);
}

unittest{
	auto fun(int x,int y=2,string z="myz"){
		import std.conv:to;
		return to!string(x)~" "~to!string(y)~" "~to!string(z);
	}
	auto ret=callNamed!(fun,`z,x`)("mynewz",100);
	assert(ret=="100 2 mynewz");
}


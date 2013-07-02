/++
2013_06_07_19_49_08
 NOTES:

support for syntax:
auto a=named!fun.z(3).x(4)();

while waiting for real named parameter syntax (if it comes): auto a=fun(z:3,x:4);

also: auto s=callNamed!(fun,`z,x`)(3,4);
given a function:
auto fun(int x,int y=2,double z=0);

Compile time errors will occur on duplicate param names, or ones that don't exist, or ones that are not optional and not provided (eg x, above)
won't work with function pointers / delegates, as ParameterDefaultValueTuple etc won't know of parameters

TODO:
support:
auto a=named!fun.z(3).y(4)(10); //for calling auto a=fun(10,4,3);
support templates
efficiency of the named!fun syntax? is there any overhead?
unittests to test that certain things don't compile

Authors: 
Timothee Cour
Jacob Carlborg for Proxy code idea in named!foo.b(3).a(5).call();
later simplified to: named!foo.b(3).a(5)();

 +/

//2013_06_28_17_06_13
module dtools.util.functional;

auto callNamed(alias fun,string s,T...)(T args)
{
	import std.traits;
	import std.array:split;
	import std.algorithm:countUntil,canFind;
	import std.algorithm:sort,uniq,walkLength;
	import std.conv:to;
	enum namesCall=split(s,",");
	static assert(namesCall.length==T.length);

	enum names=[ParameterIdentifierTuple!fun];

	int findNotIn(T)(T a,T b)
	{
		foreach(int i,ai;a)
		{
			if(!canFind(b,ai))
				return i;
		}
		return -1;
	}

	enum indBad=findNotIn(namesCall,names);
	static assert(indBad==-1,"bad param: " ~ namesCall[indBad] ~ " ; valid params: " ~ to!string(names));
	static assert(walkLength(uniq(sort(namesCall)))==namesCall.length,"called params not unique: " ~ namesCall);
	string getString()
	{
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

private struct Proxy (alias func, string parameters, Args ...)
{
	private static string addParameter (string parameters, string newParameter) ()
	{
		return parameters is null ? newParameter : parameters ~ "," ~ newParameter;
	}

	Args args;
	this(int dummy,Args args){
		static if(Args.length)
			this.args=args;
	}

	auto opDispatch (string name, T) (T value)
	{
		return Proxy!(func, addParameter!(parameters, name), Args, T)(0,args, value);
	}

	auto opCall()()
	{
		return callNamed!(func, parameters)(args);
	}
}

Proxy!(func, null) named (alias func) ()
{
	return Proxy!(func, null)(0);
}

version(unittest){
/+
TODO:
why can't fun be in the main unittest block? it gives error:
	Error: function dtools.util.functional.__unittestL111_1.Proxy!(fun, addParameter, int, int).Proxy.call!().call cannot get frame pointer to callNamed
+/
	auto fun(int x,int y=2,int z=0){
		import std.conv:to;
//		writeln(x," ",y," ",z);//TEMP
		//		import std.format;
		return to!string(x)~" "~to!string(y)~" "~to!string(z);
	}
}

unittest
{
	auto ret=callNamed!(fun,`z,x`)(3,4);
	assert(ret=="4 2 3");
	auto ret2=named!fun.z(3).x(4)();
	assert(ret2==ret);
}



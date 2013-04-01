module dtools.util.log;
import std.string;
import std.algorithm;


string parse(string s){
	import std.string:format;
	import std.ascii;
	import std.typecons;
	string ret=`format("`;
	string var;
	int nOpen=0;
	bool isParenthesized=false;//$()
	string[]args;
	void consumeVar(){
		args~=var;
		var=null;
		nOpen=0;
		ret~="%s";
	}
	foreach(i,v;s){
		if(v=='$'){
			assert(nOpen==0); 
			nOpen++;
			var=null;
			assert(i<s.length-1);
			isParenthesized=s[i+1]=='(';
			continue;
		}
		if(!nOpen){
			ret~=v;
			continue;
		}
		if(v=='('){
			assert(isParenthesized);
			nOpen++;
			if(nOpen>2)
				var~=v;
		}
		else if(v==')'){
			assert(isParenthesized);
			
			nOpen--;
			if(nOpen==1){
				consumeVar();
			}
			else
				var~=v;
		}
		else if(!isParenthesized){
			if(isAlphaNum(v) || v=='_'){
				var~=v;
			}
			else{
				consumeVar();
				ret~=v;
			}
		}
		else{
			var~=v;
		}
		
	}
	
	if(var.length)
		consumeVar();
	ret~=`"`;
	foreach(i,arg;args){
		ret~=","~arg;
	}
	ret~=`)`;
	
	return ret;
}
unittest{
	int x=1;
	double z=1.2;
	assert(mixin("variables: x=$x, z=$z, sum=$(x+z)".parse) == "variables: x=1, z=1.2, sum=2.2");
	//	assert(mixin(q{x,z,x+z}.parse2) == "x=1, z=1.2, x+z=2.2"); //TODO
}

string parse2(string file=__FILE__,int line_=__LINE__, A)(A a){
	enum line=line_;

	enum s=splitLines(import(file))[line];
	findSplit(s,"parse2(");


	import std.conv:text;
//	import std.string;
	return text(file,":",line," ",a," ",s);
}

auto findMatchingBracket(string left="(")(string a){
	import std.range:iota;
	import std.exception;
	//TODO:will it work with non-ascii?
//	static if(left=='(')
//		enum right=')';
	static if(left=="(")
		enum right=")";
	//	else static if(left=="{")
//		enum right="}";
//	else static if(left=="[")
//		enum right="]";
//	else static if(left=="<")
//		enum right=">";
	else
		static assert(0);
	int n=0;
	int i0=0;

	auto N=a.length;
	foreach(i;iota(N)){
		if(a[i..$].startsWith(left)){
			n++;
		}
		else if(a[i..$].startsWith(right)){
			n--;
			if(!n)
				return a[i0..i+1];
			else if(n<0)
				throw new Exception("parsing error at: "~a[0..i+1]);
			//					assert(0);
		}
		else{
			if(!n)
				i0++;
		}
//		a=a[1..$];
	}
	throw new Exception("parsing error at: "~a);
}

unittest{
	import std.stdio:writeln;
	writeln(findMatchingBracket("asdf(sf)ff"));
	writeln(findMatchingBracket("asdf((s(f)))ff"));
}


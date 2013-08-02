/+
2013_06_07_19_47_23

TODO:
what we really need is a parseTree function which evaluates

tree(x*(y[i]+2),foo(x)) => returns parse tree + evaluations/types at each node done by compiler

ovreload _dassertmsg etc
+/
module dtools.util.log;
import std.string;
import std.algorithm;
import std.typecons;
import std.stdio;
import std.array;
import std.conv;

auto findSplitReverse(string a,string pattern){
//TODO:move; improve
	import std.range;
	import std.algorithm;
	import std.conv;
	//return a.retro.findSplit(pattern)[0].to!string.retro.to!string; //TODO:option for just that
	auto temp=a.retro.findSplit(pattern.retro.to!string);
	Tuple!(string,string, string) ret=void;
	foreach(i,ai;temp){
		ret[i]=ai.to!string.retro.to!string;
	}
	return ret;
}
unittest{	
	assert("asdf.fun".findSplitReverse("f.")==Tuple!(string, string, string)("fun", "f.", "asd"));
}

/// usage:function_to_name(__FUNCTION__)
string function_to_name(string functionName){
//TODO:move; improve
	return functionName.findSplitReverse(".")[0];
	//import std.regex;
	//auto temp=functionName.match(regex(`\w+$`));
	//assert(temp);
	//return temp.hit;
}
unittest{
	string fun(){
		return function_to_name(__FUNCTION__);
	}
	assert(fun=="fun");
}

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

//TEMP
string parse1(string file=__FILE__,int line=__LINE__)(string s){
	enum f=import(file).splitLines[line-1];
	string name="parse";//TODO:__FUNCTION__
	auto a=findSplit(f,`".`~name);
	string f2=a[0];
	foreach(i;0..f2.length){
		if(f2[$-i-1]=='"'){
			f2=f2[$-i..$];
			break;
		}
	}
	writelnL(f);
	writelnL(f2);
	return parse_aux(f2);
}

Argument[] getArgNamesFromFile_aux(string file,int line,string function_name){
	version(all){
		//enum f=import(file).splitLines[line-1];//too slow: 22s w string import/2s wo
		import std.file;
		auto f=file.readText.splitLines[line-1];
		//enum function_name2=function_name[0..$-2];//was the old way
		auto function_name2=function_to_name(function_name);//TODO:CT or RT?
		auto a=findSplit(f,function_name2)[2];//TODO: more robust with \b lookbehind, to find a '(' after; make sure appears only once.
		return getArgNames(function_name2~a);
	}
	else{
		return Argument[].init;//no need for this if it's fast enough
	}
}
import std.functional;
alias getArgNamesFromFile=memoize!getArgNamesFromFile_aux;

//TODO:lazy args for debug stuff? handle case where could span multiple lines? maybe LINE not enough; needs COLUMN!=>DIP (in fact column range)
string parse2(string file=__FILE__,int line=__LINE__,T...)(T args){
	auto argNames=getArgNamesFromFile(file,line,__FUNCTION__);
	return formatArgs(argNames,args);
}

bool isNumberLitteral(string a){
	try{
		auto ret=a.to!double;
	}
	catch{
		return false;
	}
	return true;
	////IMPROVE
	//try{

	//}
	//auto R=regex(`^(\.?\d+|\d+\.(\d*)?)$`);
	//return a.match(R);
}

string formatArgs(T...)(Argument[]argNames,ref T args){
	if(!argNames){
		import std.range;
		import std.conv;
		argNames=T.length.iota.map!(a=>Argument(a.to!string)).array;
	}
	assert(argNames.length==T.length);
	string ret;
	foreach(i,ai;args){
		if(argNames[i].isLitteral)
			ret~=argNames[i].name;
		else
			ret~=argNames[i].name~"="~ai.to!string~"; ";
	}
	return ret;
}
struct Argument{
	string name;
	int size_comment;//includes '"'x2;
	bool isLitteral;
	bool isNumberLitteral;
	this(string name){
		this.name=name;
		this.size_comment=0;
		this.isLitteral=false;
	}
	this(string name,int size_comment){
		this.name=strip(name);
		isLitteral=this.name.length==size_comment;
		if(isLitteral){
			this.name=this.name[1..$-1]; // "abc" => abc //TODO:more robust (cf "asdf"w etc)
			//maybe not remove quote? or maybe colorize? so that we don't confuse, eg "1" and 1
		}
		else{
			isNumberLitteral=this.name.isNumberLitteral;
		}
	}
	@property bool empty(){//TODO:empty?
		return name.length==0;
	}
}
auto getArgNames(string a){
	auto b1=findMatchingBracket(a)[1];
	if(b1.length && b1[$-1].empty) //for case foo(1,)
		b1=b1[0..$-1];
	return b1;
}
auto findMatchingBracket(char left='(', char sep=',')(string a){//TODO:is char ok for unicode string?
	import std.range:iota;
	import std.exception;

	//TODO:matching left/right  at each nesting level

	//TODO:will it work with non-ascii?

	int n=0;
	int i0=0;

	size_t arg_start;

	enum lefts=['[','{','('];
	enum rights=[']','}',')'];

	enum comment_lefts=['"'];//TODO:rename as string...
	enum comment_rights=['"'];

	Argument[]arguments;
	string[]args;
	bool[]size_comments;//TODO:instead use a struct
	bool isLitteral=false;
	int size_comment=0;
	auto N=a.length;
	foreach(i;iota(N)){
		if(!isLitteral){
			if(canFind(comment_lefts,a[i])){
				isLitteral=true;
				size_comment=0;
				size_comment++;
				continue;
			}
		}
		if(isLitteral){
			size_comment++;
			if(canFind(comment_rights,a[i])){
				isLitteral=false;

			}
			continue;
		}
			
		if(canFind(lefts,a[i])){
			if(!n){
				arg_start=i+1;
			}
			n++;
		}
		else if(canFind(rights,a[i])){
			n--;
			if(!n){
				arguments~=Argument(a[arg_start..i],size_comment);//TODO:MERGE 2013_05_16_04_53_36
				return tuple(a[i0..i+1],arguments);
			}
				
			else if(n<0)//TODO:how would that be possible?
				throw new Exception("parsing error at: "~a[0..i+1]);
			//					assert(0);
		}
		else{

			if(!n)//still in prefix
				i0++;
			else if(n==1){//in outer args level
				if(a[i]==sep){
					arguments~=Argument(a[arg_start..i],size_comment);//TODO:MERGE 2013_05_16_04_53_36
					arg_start=i+1;
				}


			}
		}
	}
	//throw new Exception("parsing error at: <"~a~">");
	return typeof(return).init;//TODO: support foo.writelnL; etc
}

unittest{
	import std.stdio:writeln;
	assert(findMatchingBracket("asdf(sf)ff")[0]=="(sf)");
	assert(findMatchingBracket("asdf((s(f)))ff")[0]=="((s(f)))");
	assert(findMatchingBracket("asdf(x,y+(3*3)-1,2)f")[1].map!`a.name`.array==["x", "y+(3*3)-1", "2"]);
}
unittest{
	int x;
	auto fun(T)(T a){
		return a*a;
	}
	version(string_import){
		assert(parse2( x, x+3,fun(x+10),[x,10+(2)], "and then: ","a"~"b", 2+"12.3".to!double)==`x=0; x+3=3; fun(x+10)=100; [x,10+(2)]=[0, 12]; and then: "a"~"b"=ab; 2+"12.3".to!double=14.3; `);
		assert(parse2("special msg: " , x, x+3,fun(x+10))==`special msg: x=0; x+3=3; fun(x+10)=100; `);
		assert( parse2 ( "special msg: " , x, x+3,fun(x+10))==`special msg: x=0; x+3=3; fun(x+10)=100; `);
	}
	else{
		assert(parse2( x, x+3,fun(x+10),[x,10+(2)], "and then: ","a"~"b", 2+"12.3".to!double)==`0=0; 1=3; 2=100; 3=[0, 12]; 4=and then: ; 5=ab; 6=14.3; `);
	}
}

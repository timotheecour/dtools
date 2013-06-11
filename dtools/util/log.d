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

//TODO:lazy args for debug stuff? handle case where could span multiple lines? maybe LINE not enough; needs COLUMN!=>DIP (in fact column range)
string parse2(string file=__FILE__,int line=__LINE__,T...)(T args){
	enum f=import(file).splitLines[line-1];
	string name="parse2";//TODO:__FUNCTION__
	auto a=findSplit(f,name~`(`);//TODO: more robust with \b lookbehind
	auto args2=getArgNames(`(`~a[2]);
	return formatArgs(args2,args);
}

string formatArgs(T...)(Argument[]args2,ref T args){
	string ret;
	foreach(i,ai;args){
		if(args2[i].isComment)
			ret~=args2[i].name;
		else
			ret~=args2[i].name~"="~ai.to!string~"; ";
	}
	return ret;
}
struct Argument{
	string name;
	int size_comment;//includes '"'x2;
	bool isComment;
	@property bool isEmpty(){
		return name.length==0;
	}
	auto postproces(){//TODO:ref?use tap?
		name=strip(name);
		isComment=name.length==size_comment;
		if(isComment){
			name=name[1..$-1];
		}
		return this;
	}
}
auto getArgNames(string a){
	auto b=findMatchingBracket(a)[1];
	auto b1= b.map!(a=>a.postproces).array;
	if(b1.length && b1[$-1].isEmpty) //for case foo(1,)
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
	bool isComment=false;
	int size_comment=0;
	auto N=a.length;
	foreach(i;iota(N)){
		if(!isComment){
			if(canFind(comment_lefts,a[i])){
				isComment=true;
				size_comment=0;
				size_comment++;
				continue;
			}
		}
		if(isComment){
			size_comment++;
			if(canFind(comment_rights,a[i])){
				isComment=false;

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
	throw new Exception("parsing error at: "~a);
}

unittest{
	import std.stdio:writeln;
	assert(findMatchingBracket("asdf(sf)ff")[0]=="(sf)");
	assert(findMatchingBracket("asdf((s(f)))ff")[0]=="((s(f)))");
	assert(findMatchingBracket("asdf(x,y+(3*3)-1,2)f")[1].map!`a.name`.array==["x", "y+(3*3)-1", "2"]);
}
version(none)//TEMP
void main(){
	int x;
	auto fun(T)(T a){
		return a*a;
	}
	parse2( x, x+3,fun(x+10),[x,10+(2)], "and then: ","a"~"b", 2+"12.3".to!double).writeln;
	parse2("special msg: " , x, x+3,fun(x+10)).writeln;
}


module util.log;

import std.string:format;

string parse(string s){
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
}
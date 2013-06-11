module dtools.util.regex_funs;

/+
 quotes a so that regex will match it

  IMPROVE
 PUSH to phobos
 +/
string escapeRegex(string a){
	import std.string;
	enum transTable = (){
		string[char]b;
		auto a=`[]{}()*+?|^$\.`;
		foreach(ai;a)
		b[ai]=`\`~ai;
		return b;
	}();
	return translate(a, transTable);
}
string escapeRegexReplace(string a){
	import std.string;
	enum transTable = ['$' : `$$`]; 
	return translate(a, transTable);
}

unittest{
	import std.regex;
	string a=`asdf(def[ghi]+*|)][}{)(*+?|^$\/.`;
	assert(match(a,regex(escapeRegex(a))).hit==a);
	string b=`$aa\/$ $$#@$\0$1#$@%#@%=+_)][}{)(*+?|^$\/.`;
	auto s=replace(a,regex(escapeRegex(a)),escapeRegexReplace(b));
	assert(s==b);
}

module dtools.util.regex_funs;

/+
 quotes a so that regex will match it

 IMPROVE
 PUSH to phobos
 +/

string escapeRegex(string preserved=null)(string a){
	import std.string;
	enum transTable = (){
		string[char]b;
		enum a=`[]{}()*+?|^$\.`;
		if(preserved){
			import std.algorithm;
			import std.array;
			import std.conv;
			//Error: _adSortChar cannot be interpreted at compile time, because it has no available source code
			//			a=setDifference(a.dup.sort, preserved.dup.sort).array.to!string;
		}
		import std.algorithm;
		foreach(ai;preserved){
			assert(a.canFind(ai));
		}
		foreach(ai;a){
			if(!preserved.canFind(ai))
			b[ai]=`\`~ai;
		}
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

	//	a=`tests.test_traits.E7!(__lambda45, float)`;
	a=`tests.test_traits.E7!(__lambda\d+, float)`;
	b=`tests\.test_traits\.E7!\(__lambda\d+, float\)`;
	assert(a.escapeRegex!`\+`==b);
}

unittest{
	import std.algorithm;
	import std.array;
	assert(setDifference(`[]{}()*+?|^$\.`.dup.sort, `\+`.dup.sort).array.sort.equal(`[]{}()*?|^$.`.dup.sort));
}

auto regexCaptureEscaped(string preserved=null)(string a, string pattern){//TODO:remove?
	return regexFull(a,pattern.escapeRegex!preserved);
}

auto regexFull(string a,string pattern){
	import std.regex;
	return match(a,regex(`^`~pattern~`$`));
}
//TODO:unittest

bool isExactMatch(string preserved)(string a,string pattern){
	auto b=regexCaptureEscaped!preserved(a,pattern);
	return (b && b.hit==a);
}
unittest{
	assert(isExactMatch!`\+`(`tests.test_traits.E7!(__lambda123, float)`,`tests.test_traits.E7!(__lambda\d+, float)`));
	assert(!isExactMatch!`\+`(`tests.test_traits.E7!(__lambda1a3, float)`,`tests.test_traits.E7!(__lambda\d+, float)`));
}



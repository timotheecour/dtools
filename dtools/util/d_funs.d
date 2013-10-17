/+
2013_06_07_19_51_01
+/
module dtools.util.d_funs;

import std.file;
import std.stdio;
import std.string;
import std.conv;
import std.traits;
import std.process;

@property getTmpFile(){
//	return tmpDir~tmpfile~".txt";
	return "/tmp/d_funs_mixin_insight.d"; //TEMP
}
template IdentityMixin(string s,alias val,string file,int line){
	enum t=typeof(val).stringof;
	//	enum t=fullyQualifiedName!(typeof(val));
	pragma(msg,"mixin insight: "~file~":"~line.to!string~": "~s~"=("~t~")",val);
	enum IdentityMixin=val;
}

void test(string file){
	auto temp=instrumentMixins(file.readText);
//	writeln(temp);
}

version(is_main)
void main(string[]args){//TEMP
	test(args[1]);
}

private:
string instrumentMixins(string text){
	import std.regex;
	auto r=regex(`mixin\(([^\)]+)\)`,"gm");//TODO:IMPROVE
	text=replace(text,r,instrumentMixin(`$1`));

	text~="\nversion(all): import dtools.util.d_funs;\n"; //TODO:less fragile


//	auto file=envs["tmp_D_D"]~"temp_instrumentMixins.d";//PATH TEMP
	auto file=getTmpFile;


//	auto file=tmpFileManaged(".d");
	std.file.write(file,text);
//	return systemCaptureThrow("rdmd --build-only -c "~file).output;
	int ret = system("rdmd --build-only -c 2>&1 "~file);
	import std.file;

	string text2=readText(file);
	if(ret){
		writeln(ret);
		writeln(text2);
		assert(0);
	}
	return text2;
}

string instrumentMixin(string text){
	return `IdentityMixin!(`~text~`,mixin(`~text~`),__FILE__,__LINE__)`;
}
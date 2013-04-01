module dtools.temp.monod_plugin_1;
import std.stdio;

version(json){
	//TODO
	import std.json;
	int main(string[]args){
		string input=args[0];
		return 0;
		//TODO
	}
}
else version(simple){
	import std.getopt;
	import std.file;
	import std.string;
	

//	string text = ""; //TODO:support
	string file = "";
	int index_begin = 0;
	int index_end = 0;
	enum Operation { toUpper, toLower };
	Operation operation;

	int main(string[]args){
		getopt(
			args,
			"index_begin",  &index_begin,
			"index_end",    &index_end,
			"operation",   &operation,
			"file",   &file,
//			"text",   &text,
			);

		string text=file.readText;
		string text2=text[index_begin..index_end];
		string output;
		final switch(operation){
			case Operation.toUpper:
				output=toUpper(text2);
				break;
			case Operation.toLower:
				output=toLower(text2);
				break;
		}
		writeln(output);
		return 0;
	}

}

module dtools.util.versions;

enum versions=(){
	struct versions_{
		bool has(alias a)(){
		mixin(`
	version(`~a~`){
		return true;
	}
	else 
		return false;
`);
		}

//		alias has this;
		//TODO:how to have instead opIndex instead of has?
		auto opDispatch(string a)(){
			mixin(`
	version(`~a~`){
		return true;
	}
	else 
		return false;
`);
		}
	}
	return versions_.init;
}();

version(none){
	template Version(alias V){
		mixin(`
	version(`~V~`){
		enum Version=true;
	}
	else 
		enum Version=false;
`);
	}

	template Debug(alias V){
		import std.traits:isIntegral;
		static if(!isIntegral!(typeof(V))){
			mixin(`
	debug(`~V~`){
		enum Debug=true;
	}
	else 
		enum Debug=false;
`);
		}
		else{
			import std.conv:to;
			mixin(`
	debug(`~V.to!string~`){
		enum Debug=true;
	}
	else 
		enum Debug=false;
`);
			/+
			 //NOTE:maybe a dmd bug but this didn't work
			 debug(V){
			 enum Debug=true;
			 }
			 else 
			 enum Debug=false;
			 +/
		}		
	}
}

version(none)//to disable printing
unittest{//TODO:improve unittest
	import std.stdio;
	writeln(__MODULE__,":begin");
	static if(versions.v1 || versions.v2){writeln("v1||v2");}
	static if(versions.v1 && !versions.v2){writeln("v1 && !v2");}
	//also support doing it like that, in order to support special keywords like assert.
	static if(versions.has!"assert"){writeln("assert");}
	//would prefer versions["assert"] but not sure how to support that with versions.v1
	writeln(__MODULE__,":end");
}

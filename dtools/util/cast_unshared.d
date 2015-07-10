module dtools.util.cast_unshared;
//MERGE(dtools.util.cast_funs)

template CastUnshared(T){
  import std.traits:isAssociativeArray,ValueType,KeyType,isArray,ForeachType,isPointer,PointerTarget,isStaticArray;
  static if(isAssociativeArray!T){
    alias CastUnshared=CastUnshared!(ValueType!T)[CastUnshared!(KeyType!T)];
  }
  else static if(isStaticArray!T){
    alias CastUnshared=CastUnshared!(ForeachType!T)[T.length];
  }
  else static if(isArray!T){
    //TODO:ForeachType or ElementType?
    alias CastUnshared=CastUnshared!(ForeachType!T)[];
  }
  else static if(isPointer!T){
    //pragma(msg,__LINE__, ":", T.stringof);
    alias CastUnshared=CastUnshared!(PointerTarget!T)*;
  }
  //}
  else static if(is(T==shared(U), U)) {
    //pragma(msg,__LINE__, ":", T.stringof);
    alias CastUnshared=CastUnshared!U;
  }
  else{
    //pragma(msg,__LINE__, ":", T.stringof);
    //alias CastUnshared=typeof(cast()T.init);//BAD:removes immutable etc
    alias CastUnshared=T;
  }
}

unittest{
  {
    alias T=shared(int[string]);
    static assert(is(CastUnshared!T==int[string]));
  }
  {
    alias T=shared(int[]);
    static assert(is(CastUnshared!T==int[]));
  }
}

auto ref castUnshared(T)(auto ref shared(T) a){
  //TODO:http://dlang.org/faq.html#casting_to_shared
  return cast(CastUnshared!T) a;
}


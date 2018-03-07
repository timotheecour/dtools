module dtools.alloc;

// IMPROVE using std.experimental.allocator?
T[] mallocT(T)(size_t length) @nogc nothrow
{
  import core.stdc.stdlib:malloc;
  auto ptr=malloc(length*T.sizeof);
  assert(ptr);
  return (cast(T*)ptr)[0..length];
}

T[] reallocT(T)(T[] a, size_t length) @nogc nothrow
{
  import core.stdc.stdlib:realloc;
  auto ptr=realloc(a.ptr, length*T.sizeof);
  assert(ptr);
  return (cast(T*)ptr)[0..length];
}

// RENAME
auto malloc_cpy(T)(T a, bool trailing0)  @nogc nothrow
{
  import std.traits:Unqual;
  alias T2=Unqual!(typeof(a[0]));

  auto L=a.length;
  auto L2=L + (trailing0?1:0);
  auto ret2=L2.mallocT!T2;
  ret2[0..L] = a[0..L];
  if(trailing0)
    ret2[L2-1]=0;
  return ret2;
}

T[] getDst(T)(size_t n) pure @trusted nothrow
{
    try
    {
        auto fun = cast(T[] function(size_t) pure) &getDstImpl!T;
        return fun(n);
    }
    catch(Throwable t)
    {
        assert(0);
    }
}

//import core.sync.mutex;
//private static shared Mutex mtx;
//static shared Mutex mtx;
//import std.concurrency;
private T[] getDstImpl(T)(size_t n) @nogc nothrow
{
    //initOnce!mtx(new shared Mutex);
    // TODO: make safe
    __gshared T[]dst=null;
    //mtx.lock_nothrow();
    if(dst.length>=n) return dst;
    import dtools.alloc:reallocT;
    dst=dst.reallocT(n);
    //mtx.unlock_nothrow();
    return dst;
}

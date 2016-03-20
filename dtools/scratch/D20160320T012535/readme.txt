ldc2 -c -od=/tmp/d05 fun1.d
gives Error: Internal Compiler Error:

std/format.d(1): Error: function declaration without return type. (Note that constructors are always named 'this')
std/format.d(2): Error: no identifier for declarator void()
std/format.d(3): Error: semicolon expected following function declaration
std/format.d(3): Error: basic type expected, not )
std/format.d(4): Error: basic type expected, not )
std/format.d(4): Error: (arguments) expected following immutable(int)
std/format.d(9): Error: basic type expected, not ;
std/format.d(24): Error: constructor format.Appender!(immutable(int)).Appender.this (int _param_0) is not callable using argument types (typeof(null))
std/format.d(4): Error: template instance format.appender!(immutable(int)) error instantiating
std/typecons.d(7):        instantiated from here: format!()
fun2.d(21):        instantiated from here: Tuple!int
fun2.d(13):        instantiated from here: memoize!(fun2)
std/typecons.d(3): Error: function typecons.Tuple!int.injectNamedFields has no return statement, but is expected to return a value of type string
fun2.d(9): Error: template instance fun2.c!() error instantiating
Error: Internal Compiler Error: function not fully analyzed; previous unreported errors compiling format.Appender!(immutable(int)).Appender.Data.__xopEquals?

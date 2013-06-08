import dtools.util.cast_funs;
import util.util;
void test_Cast(){
	int a=1;
	//	auto b=a.Cast!double;
	auto b=(a+a).Cast!double;
	writelnL(a,b,&a,&b,cast(void*)&a==cast(void*)&b);
	writelnL(a.Cast!Signed);
	writelnL(a.Cast!Unsigned);
	writelnL(a.Cast!Const);
	writelnL(a.Cast!Immutable);
//	writelnL(typeid(a.Cast!Immutable.Typeof));
	pragma(msg,typeof(a.Cast!Immutable));
	//	writelnL(a.Cast!Immutable.Typeof.typeid);
	//	static assert(is(a.Cast!Immutable.Typeof==immutable(int)));
	//	static assert(is(a.Cast!Immutable.Typeof==immutable(int)));
}

void main(){
	test_Cast;
}
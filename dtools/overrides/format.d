module dtools.overrides.format;

import std.stdio;
import std.format;
import std.range;
import std.ascii;
import std.conv;
import std.traits;
import std.typecons;
import std.exception;
import std.math:isnan;

private void skipData(Range, Char)(ref Range input, ref FormatSpec!Char spec)
{
	switch (spec.spec)
	{
		case 'c': input.popFront(); break;
		case 'd':
			if (input.front == '+' || input.front == '-') input.popFront();
			goto case 'u';
		case 'u':
			while (!input.empty && isDigit(input.front)) input.popFront();
			break;
		default:
			assert(false,
			       text("Format specifier not understood: %", spec.spec));
	}
}
uint formattedRead(R, Char, S...)(ref R r, const(Char)[] fmt, ref S args)
{
	auto spec = FormatSpec!Char(fmt);
	static if (!S.length)
	{
		spec.readUpToNextSpec(r);
		enforce(spec.trailing.empty);
		return 0;
	}
	else
	{
		// The function below accounts for '*' == fields meant to be
		// read and skipped
		void skipUnstoredFields()
		{
			for (;;)
			{
				spec.readUpToNextSpec(r);
				if (spec.width != spec.DYNAMIC) break;
				// must skip this field
				skipData(r, spec);
			}
		}
		
		skipUnstoredFields();
		if (r.empty)
		{
			// Input is empty, nothing to read
			return 0;
		}
		alias typeof(args[0]) A;
		static if (isTuple!A)
		{
			foreach (i, T; A.Types)
			{
				(args[0])[i] = unformatValue!(T)(r, spec);
				skipUnstoredFields();
			}
		}
		else
		{
			args[0] = unformatValue!(A)(r, spec);
		}
		return 1 + formattedRead(r, spec.trailing, args[1 .. $]);
	}
}

unittest
{
	string s = " 1.2 3.4 ";
	double x, y, z;
	assert(formattedRead(s, " %s %s %s ", x, y, z) == 2);
	assert(s.empty);
	assert(x == 1.2);
	assert(y == 3.4);
	assert(isnan(z));
}

version(none)unittest
{
	union A
	{
		char[float.sizeof] untyped;
		float typed;
	}
	A a;
	a.typed = 5.5;
	char[] input = a.untyped[];
	float witness;
	formattedRead(input, "%r", witness);
	assert(witness == a.typed);
}
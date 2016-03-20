template Tuple(Specs)
{
    string injectNamedFields()
    {
        import std.format;

        format;
    }

    struct Tuple
    {
        mixin(injectNamedFields);

    }
}

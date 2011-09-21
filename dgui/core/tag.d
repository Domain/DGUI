module dgui.core.tag;

public import std.variant;

mixin template TagProperty()
{
	private Variant _tt;

	/*
	 *	DMD 2.052 BUG: Cannot differentiate var(T)() and var(T)(T t)
	 *	template functions, use variadic template with length check.
	 */
	@property public T[0] tag(T...)()
	{
		static assert(T.length == 1, "Multiple parameters not allowed");
		return this._tt.get!(T[0]);
	}

	@property public void tag(T)(T t)
	{
		this._tt = t;
	}
}

module dgui.core.collection;

import std.stdio;

class Collection(T)
{
	private T[] _t;

	public final int add(T t)
	{
		this._t ~= t;
		return this._t.length - 1;
	}

	public final void clear()
	{
		this._t.length = 0;
	}

	public final int length()
	{
		return this._t.length;
	}

	public final void remove(T t)
	{
		this.removeAt(this.find(t));
	}

	public final void removeAt(int idx)
	{
		int x = 0;
		T[] newT = new T[this._t.length - 1];

		foreach(int i, T t; this._t)
		{
			if(i != idx)
			{
				newT[x] = t;
				x++;
			}
		}

		this._t = newT;
	}

	public final int find(T t)
	{
		foreach(int i, T ft; this._t)
		{
			if(ft is t)
			{
				return i;
			}
		}

		return -1;
	}

	public T opIndex(int i)
	{
		if(i >= 0 && i < this._t.length)
		{
			return this._t[i];
		}

		return null;
	}

	public int opApply(int delegate(ref T) dg)
	{
		int res = 0;

		if(this._t.length)
		{
			for(int i = 0; i < this._t.length; i++)
			{
				res = dg(this._t[i]);

				if(res)
				{
					break;
				}
			}
		}

		return res;
	}

	public int opApply(int delegate(ref int, ref T) dg)
	{
		int res = 0;

		if(this._t.length)
		{
			for(int i = 0; i < this._t.length; i++)
			{
				res = dg(i, this._t[i]);

				if(res)
				{
					break;
				}
			}
		}

		return res;
	}
}

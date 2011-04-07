/*
	Copyright (c) 2011 Trogu Antonio Davide

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module dgui.core.geometry;

import dgui.core.winapi;

struct Rect
{
	public union
	{
		struct
		{
			uint left = 0;
			uint top = 0;
			uint right = 0;
			uint bottom = 0;
		}

		RECT rect;
	}

	public static Rect opCall(Point pt, Size sz)
	{
		return opCall(pt.x, pt.y, sz.width, sz.height);
	}

	public static Rect opCall(uint l, uint t, uint w, uint h)
	{
		Rect r = void; //Viene inizializzata sotto.

		r.left = l;
		r.top = t;
		r.right = l + w;
		r.bottom = t + h;

		return r;
	}

	public const bool opEquals(ref const Rect r)
	{
		return this.left == r.left && this.top == r.top && this.right == r.right && this.bottom == r.bottom;
	}

	public @property int x()
	{
		return this.left;
	}

	public @property void x(int newX)
	{
		int w = this.width;

		this.left = newX;
		this.right = newX + w;
	}

	public @property int y()
	{
		return this.top;
	}

	public @property void y(int newY)
	{
		int h = this.height;

		this.top = newY;
		this.bottom = newY + h;
	}

	public @property int width()
	{
		return this.right - this.left;
	}

	public @property void width(int w)
	{
		this.right = this.left + w;
	}

	public @property int height()
	{
		return this.bottom - this.top;
	}

	public @property void height(int h)
	{
		this.bottom = this.top + h;
	}

	public @property Point location()
	{
		return Point(this.left, this.top);
	}

	public @property void location(Point pt)
	{
		Size sz = this.size; //Copia dimensioni

		this.left = pt.x;
		this.top = pt.y;
		this.right = this.left + sz.width;
		this.bottom = this.top + sz.height;
	}

	public @property Size size()
	{
		return Size(this.width, this.height);
	}

	public @property void size(Size sz)
	{
		this.right = this.left + sz.width;
		this.bottom = this.top + sz.height;
	}

	public @property bool empty()
	{
		return this.width <= 0 && this.height <= 0;
	}

	public static Rect fromRECT(RECT* pWinRect)
	{
		Rect r = void; //Inizializzata sotto

		r.rect = *pWinRect;
		return r;
	}
}

struct Point
{
	public union
	{
		struct
		{
			uint x = 0;
			uint y = 0;
		}

		POINT point;
	}

	public bool opEquals(ref const Point pt) const
	{
		return this.x == pt.x && this.y == pt.y;
	}

	public static Point opCall(int x, int y)
	{
		Point pt = void; //Viene inizializzata sotto.

		pt.x = x;
		pt.y = y;
		return pt;
	}
}

struct Size
{
	public union
	{
		struct
		{
			uint width = 0;
			uint height = 0;
		}

		SIZE size;
	}

	public bool opEquals(ref const Size sz) const
	{
		return this.width == sz.width && this.height == sz.height;
	}

	public static Size opCall(int w, int h)
	{
		Size sz = void;

		sz.width = w;
		sz.height = h;
		return sz;
	}
}

public const Rect NullRect; // = Rect.init;
public const Point NullPoint; // = Point.init;
public const Size NullSize; // = Size.init;

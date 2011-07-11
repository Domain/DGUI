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

module dgui.core.events;

import dgui.core.winapi;
import dgui.core.enums;
import dgui.canvas;

class EventArgs
{
	private static EventArgs _empty;

	private this()
	{

	}

	@property public static EventArgs empty()
	{
		if(!this._empty)
		{
			_empty = new EventArgs();
		}

		return _empty;
	}
}

class CancelEventArgs: EventArgs
{
	private bool _cancel = false;

	@property public bool cancel()
	{
		return this._cancel;
	}

	@property public void cancel(bool b)
	{
		this._cancel = b;
	}
}

class PaintEventArgs: EventArgs
{
	private Canvas _canvas;
	private Rect _clipRectangle;

	public this(Canvas c, Rect r)
	{
		this._canvas = c;
		this._clipRectangle = r;
	}

	@property public final Canvas canvas()
	{
		return this._canvas;
	}

	@property public final Rect clipRectangle()
	{
		return this._clipRectangle;
	}
}

class DrawItemEventArgs: EventArgs
{
	private DrawItemState _state;
	private Color _foreColor;
	private Color _backColor;
	private Canvas _canvas;
	private Rect _itemRect;
	private int _index;

	public this(Canvas c, DrawItemState state, Rect itemRect, Color foreColor, Color backColor, int index)
	{
		this._canvas = c;
		this._state = state;
		this._itemRect = itemRect;
		this._foreColor = foreColor;
		this._backColor = backColor;
		this._index = index;
	}

	@property public Canvas canvas()
	{
		return this._canvas;
	}

	@property public DrawItemState itemState()
	{
		return this._state;
	}

	@property public Rect itemRect()
	{
		return this._itemRect;
	}

	@property public Color foreColor()
	{
		return this._foreColor;
	}

	@property public Color backColor()
	{
		return this._backColor;
	}

	public void drawBackground()
	{
		scope SolidBrush brush = new SolidBrush(this._backColor);
		this._canvas.fillRectangle(brush, this._itemRect);
	}

	public void drawFocusRect()
	{
		if(this._state & DrawItemState.FOCUSED)
		{
			DrawFocusRect(this._canvas.handle, &this._itemRect.rect);
		}
	}

	@property public int index()
	{
		return this._index;
	}
}

class MeasureItemEventArgs: EventArgs
{
	private int _width;
	private int _height;
	private int _index;
	private Canvas _canvas;

	public this(Canvas c, int width, int height, int index)
	{
		this._canvas = c;
		this._width = width;
		this._height = height;
		this._index = index;
	}

	@property public Canvas canvas()
	{
		return this._canvas;
	}

	@property public int width()
	{
		return this._width;
	}

	@property public void width(int w)
	{
		this._width = w;
	}

	@property public int height()
	{
		return this._height;
	}

	@property public void height(int h)
	{
		this._height = h;
	}

	@property public int index()
	{
		return this._index;
	}
}

class MouseEventArgs: EventArgs
{
	private MouseKeys _mKeys;
	private Point _cursorPos;

	public this(Point cursorPos, MouseKeys mk)
	{
		this._cursorPos = cursorPos;
		this._mKeys = mk;
	}

	@property public Point location()
	{
		return this._cursorPos;
	}

	@property public MouseKeys keys()
	{
		return this._mKeys;
	}
}

class MouseWheelEventArgs: MouseEventArgs
{
	private MouseWheel _mw;

	public this(Point cursorPos, MouseKeys mk, MouseWheel mw)
	{
		this._mw = mw;

		super(cursorPos, mk);
	}

	@property public MouseWheel wheel()
	{
		return this._mw;
	}
}

class ScrollEventArgs: EventArgs
{
	private ScrollDir _dir;
	private ScrollMode _mode;

	public this(ScrollDir sd, ScrollMode sm)
	{
		this._dir = sd;
		this._mode = sm;
	}

	@property public ScrollDir direction()
	{
		return this._dir;
	}

	@property public ScrollMode mode()
	{
		return this._mode;
	}
}

class KeyEventArgs: EventArgs
{
	private Keys _keys;
	private bool _handled = true;

	public this(Keys keys)
	{
		this._keys = keys;
	}

	@property public Keys keyCode()
	{
		return this._keys;
	}

	@property public bool handled()
	{
		return this._handled;
	}

	@property public void handled(bool b)
	{
		this._handled = b;
	}
}

class KeyCharEventArgs: KeyEventArgs
{
	private char _keyChar;

	public this(Keys keys, char keyCh)
	{
		super(keys);
		this._keyChar = keyCh;
	}

	@property public char keyChar()
	{
		return this._keyChar;
	}
}

class ItemEventArgs(T): EventArgs
{
	private T _checkedItem;

	public this(T item)
	{
		this._checkedItem = item;
	}

	@property public T item()
	{
		return this._checkedItem;
	}
}

class ItemChangedEventArgs(T): EventArgs
{
	private T _oldItem;
	private T _newItem;

	public this(T oItem, T nItem)
	{
		this._oldItem = oItem;
		this._newItem = nItem;
	}

	@property public T oldItem()
	{
		return this._oldItem;
	}

	@property public T newItem()
	{
		return this._newItem;
	}
}

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

module dgui.splitter;

import dgui.control;

private const int SPLITTER_SIZE = 6;
private const ubyte[] BITMAP_BITS = [ 0xAA, 0, 0x55, 0, 0xAA, 0, 0x55, 0,
									  0xAA, 0, 0x55, 0, 0xAA, 0, 0x55, 0, ];

class Splitter: Control
{
	private static HBRUSH _hXorBrush;
	private Rect _prevPos;
	private int _downpos;
	private int _lastpos;
	private bool _downing = false;
	private bool _mgrip = true;

	public this()
	{
		if(!_hXorBrush)
		{
			HBITMAP hBitmap = CreateBitmap(8, 8, 1, 1, BITMAP_BITS.ptr);
			this._hXorBrush = CreatePatternBrush(hBitmap);
			DeleteObject(hBitmap);
		}
	}

	private void doSplit()
	{
		Point pt = Cursor.location;
		convertPoint(pt, null, this.parent);
		Control splitCtrl = this.splitControl();

		if(splitCtrl)
		{
			switch(this.dock)
			{
				case DockStyle.LEFT:
					splitCtrl.width = pt.x;
					break;

				case DockStyle.TOP:
					splitCtrl.height = pt.y;
					break;

				case DockStyle.RIGHT:
					splitCtrl.width = splitCtrl.width - ((pt.x + SPLITTER_SIZE) - splitCtrl.location.x);
					break;

				case DockStyle.BOTTOM:
					splitCtrl.height = splitCtrl.height - ((pt.y + SPLITTER_SIZE) - splitCtrl.location.y);
					break;

				default:
					break;
			}

			this.parent.doDock();
		}
	}

	@property private Control splitControl()
	{
		Control ctrl;

		switch(this.dock)
		{
			case DockStyle.LEFT:
			{
				foreach(Control c; this.parent.controls)
				{
					if(c.dock != DockStyle.LEFT)
					{
						continue;
					}

					if(c == cast(Control)this)
					{
						return ctrl;
					}

					ctrl = c;
				}
			}
			break;

			case DockStyle.TOP:
			{
				foreach(Control c; this.parent.controls)
				{
					if(c.dock != DockStyle.TOP)
					{
						continue;
					}

					if(c == cast(Control)this)
					{
						return ctrl;
					}

					ctrl = c;
				}
			}
			break;

			case DockStyle.RIGHT:
			{
				foreach(Control c; this.parent.controls)
				{
					if(c.dock != DockStyle.RIGHT)
					{
						continue;
					}

					if(c == cast(Control)this)
					{
						return ctrl;
					}

					ctrl = c;
				}
			}
			break;

			case DockStyle.BOTTOM:
			{
				foreach(Control c; this.parent.controls)
				{
					if(c.dock != DockStyle.BOTTOM)
					{
						continue;
					}

					if(c == cast(Control)this)
					{
						return ctrl;
					}

					ctrl = c;
				}
			}
			break;

			default:
				break;
		}

		return null;
	}

	private static void drawBullets(Canvas c, DockStyle dock, Rect paintRect)
	{
		const int SPACE = 5;
		const int WIDTH = 3;
		const int HEIGHT = 3;

		void drawSingleBullet(int x, int y)
		{
			static Pen dp;
			static Pen lp;

			if(!dp && !lp)
			{
				dp = new Pen(SystemColors.color3DdarkShadow, 2, PenStyle.DOT);
				lp = new Pen(SystemColors.color3DLight, 2, PenStyle.DOT);
			}

			c.drawLine(dp, x, y, x, y + 2);
			c.drawLine(lp, x - 1, y - 1, x - 1, (y - 1) + 2);
		}

		switch(dock)
		{
			case DockStyle.LEFT, DockStyle.RIGHT:
			{
				int x = (paintRect.width / 2) - (WIDTH / 2);
				int y = (paintRect.height / 2) - 15;

				for(int i = 0; i < 5; i++, y += HEIGHT + SPACE)
				{
					drawSingleBullet(x, y);
				}
			}
			break;

			case DockStyle.TOP, DockStyle.BOTTOM:
			{
				int x = (paintRect.width / 2) - 15;
				int y = (paintRect.height / 2) - 1;

				for(int i = 0; i < 5; i++, x += HEIGHT + SPACE)
				{
					drawSingleBullet(x, y);
				}
			}
			break;

			default:
				break;
		}
	}

	private static void drawXorBar(HDC hdc, Rect r)
	{
		SetBrushOrgEx(hdc, r.x, r.y, null);
		HBRUSH hOldBrush = SelectObject(hdc, this._hXorBrush);
		PatBlt(hdc, r.x, r.y, r.width, r.height, PATINVERT);
		SelectObject(hdc, hOldBrush);
	}

	private void drawXorClient(HDC hdc, int x, int y)
	{
		Point pt = Point(x, y);

		convertPoint(pt, this, this.parent);
		drawXorBar(hdc, Rect(pt, this.size));
	}

	private void drawXorClient(int x, int y, int xold = int.min, int yold = int.min)
	{
		HDC hdc = GetDCEx(this.parent.handle, null, DCX_CACHE);

		if(xold != int.min)
		{
			this.drawXorClient(hdc, xold, yold);
		}

		this.drawXorClient(hdc, x, y);
		ReleaseDC(null, hdc);
	}

	private void initSplit(Point pos)
	{
		this._downing = true;

		switch(dock)
		{
			case DockStyle.TOP, DockStyle.BOTTOM:
				this._downpos = pos.y;
				this._lastpos = 0;
				this.drawXorClient(0, this._lastpos);
				break;

			default: // LEFT / RIGHT.
				this._downpos = pos.x;
				this._lastpos = 0;
				this.drawXorClient(this._lastpos, 0);
				break;
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DSPLITTER;
		pcw.ClassStyle = ClassStyles.HREDRAW | ClassStyles.VREDRAW;

		if(this._controlInfo.Dock is DockStyle.LEFT || this._controlInfo.Dock is DockStyle.RIGHT)
		{
			pcw.DefaultCursor = SystemCursors.sizeNS;
		}
		else
		{
			pcw.DefaultCursor = SystemCursors.sizeWE;
		}

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		switch(this.dock)
		{
			case DockStyle.LEFT, DockStyle.RIGHT:
				this.cursor = SystemCursors.sizeWE;
				this.bounds = Rect(0, 0, SPLITTER_SIZE, 0);
				this.size = Size(SPLITTER_SIZE, this.height);
				break;

			case DockStyle.TOP, DockStyle.BOTTOM:
				this.cursor = SystemCursors.sizeNS;
				this.bounds = Rect(0, 0, 0, SPLITTER_SIZE);
				this.size = Size(this.width, SPLITTER_SIZE);
				break;

			default:
				throwException!(DGuiException)("Invalid DockSyle");
		}

		super.onHandleCreated(e);
	}

	protected override void onMouseKeyDown(MouseEventArgs e)
	{
		if(e.keys == MouseKeys.LEFT)
		{
			this._downing = true;
			SetCapture(this._handle);
			this.initSplit(e.location);
		}

		super.onMouseKeyDown(e);
	}

	protected override void onMouseKeyUp(MouseEventArgs e)
	{
		if(this._downing)
		{
			this._downing = false;

			switch(this.dock)
			{
				case DockStyle.TOP, DockStyle.BOTTOM:
					this.drawXorClient(0, this._lastpos);
					break;

				default: // LEFT / RIGHT.
					this.drawXorClient(this._lastpos, 0);
					break;
			}

			ReleaseCapture();
			this.doSplit();
		}

		super.onMouseKeyUp(e);
	}

	protected override void onMouseMove(MouseEventArgs e)
	{
		if(this._downing)
		{
			Point pt = Cursor.location;
			convertPoint(pt, null, this);

			switch(dock)
			{
				case DockStyle.TOP, DockStyle.BOTTOM:
					this.drawXorClient(0, pt.y - this._downpos, 0, this._lastpos);
					this._lastpos = pt.y - this._downpos;
					break;

				default: // LEFT / RIGHT.
					this.drawXorClient(pt.x - this._downpos, 0, this._lastpos, 0);
					this._lastpos = pt.x - this._downpos;
					break;
			}
		}

		super.onMouseMove(e);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		Rect r = void;
		GetClientRect(this._handle, &r.rect);
		drawBullets(e.canvas, this.dock, r);

		super.onPaint(e);
	}
}

module dgui.layout.splitpanel;

import dgui.core.events.event;
import dgui.core.events.eventargs;
import dgui.layout.layoutcontrol;
import dgui.layout.panel;

enum SplitOrientation
{
	VERTICAL   = 1,
	HORIZONTAL = 2,
}

class SplitPanel: LayoutControl
{
	private const int SPLITTER_SIZE = 8;

	private SplitOrientation _splitOrientation = SplitOrientation.VERTICAL;
	private bool _downing = false;
	private int _splitPos = 0;
	private Panel _panel1;
	private Panel _panel2;

	public this()
	{
		this._panel1 = new Panel();
		this._panel1.parent = this;

		this._panel2 = new Panel();
		this._panel2.parent = this;
	}

	@property public void splitPosition(int sp)
	{
		this._splitPos = sp;

		if(this.created)
		{
			this.updateLayout();
		}
	}

	@property public Panel panel1()
	{
		return this._panel1;
	}

	@property public Panel panel2()
	{
		return this._panel2;
	}

	@property SplitOrientation splitOrientation()
	{
		return this._splitOrientation;
	}

	@property void splitOrientation(SplitOrientation so)
	{
		this._splitOrientation = so;
	}

	public override void updateLayout()
	{
		if(!this._splitPos && !this._downing)
		{
			switch(this._splitOrientation)
			{
				case SplitOrientation.VERTICAL:
					this._splitPos = this.width / 3;
					break;

				default: // SplitOrientation.HORIZONTAL
					this._splitPos = this.height / 3;
					break;
			}
		}

		switch(this._splitOrientation)
		{
			case SplitOrientation.VERTICAL:
				this._panel1.bounds = Rect(0, 0, this._splitPos, this.height);
				this._panel2.bounds = Rect(this._splitPos + SPLITTER_SIZE, 0, this.width - (this._splitPos + SPLITTER_SIZE), this.height);
				break;

			default: // SplitOrientation.HORIZONTAL
				this._panel1.bounds = Rect(0, 0, this.width, this._splitPos);
				this._panel2.bounds = Rect(0, this._splitPos + SPLITTER_SIZE, this.width, this.height - (this._splitPos + SPLITTER_SIZE));
				break;
		}

		this.invalidate();
	}

	protected override void onMouseKeyDown(MouseEventArgs e)
	{
		if(e.keys == MouseKeys.LEFT)
		{
			this._downing = true;
			SetCapture(this._handle);
		}

		super.onMouseKeyDown(e);
	}

	protected override void onMouseKeyUp(MouseEventArgs e)
	{
		if(this._downing)
		{
			this._downing = false;
			ReleaseCapture();
		}

		super.onMouseKeyUp(e);
	}

	protected override void onMouseMove(MouseEventArgs e)
	{
		if(this._downing)
		{
			Point pt = Cursor.location;
			convertPoint(pt, null, this);

			switch(this._splitOrientation)
			{
				case SplitOrientation.VERTICAL:
					this._splitPos = pt.x;
					break;

				default: // SplitOrientation.HORIZONTAL
					this._splitPos = pt.y;
					break;
			}

			this.updateLayout();
		}

		super.onMouseMove(e);
	}

	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.ClassName = WC_DSPLITPANEL;

		switch(this._splitOrientation)
		{
			case SplitOrientation.VERTICAL:
				ccp.DefaultCursor = SystemCursors.sizeWE;
				break;

			default: // SplitOrientation.HORIZONTAL
				ccp.DefaultCursor = SystemCursors.sizeNS;
				break;
		}

		super.createControlParams(ccp);
	}

	protected override void onDGuiMessage(ref Message m)
	{
		switch(m.Msg)
		{
			case DGUI_ADDCHILDCONTROL:
			{
				Control c = winCast!(Control)(m.wParam);

				if(c is this._panel1 || c is this._panel2)
				{
					super.onDGuiMessage(m);
				}
				else
				{
					throwException!(DGuiException)("SplitPanel doesn't accept child controls");
				}
			}
			break;

			default:
				super.onDGuiMessage(m);
				break;
		}
	}

	protected override void onHandleCreated(EventArgs e)
	{
		switch(this._splitOrientation)
		{
			case SplitOrientation.VERTICAL:
				this.cursor = SystemCursors.sizeWE;
				break;

			default: // SplitOrientation.HORIZONTAL
				this.cursor = SystemCursors.sizeNS;
				break;
		}

		super.onHandleCreated(e);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		Canvas c = e.canvas;
		Rect cr = e.clipRectangle;
		int mid = this._splitPos + (SPLITTER_SIZE / 2);
		scope Pen dp = new Pen(SystemColors.color3DdarkShadow, 2, PenStyle.DOT);
		scope Pen lp = new Pen(SystemColors.colorBtnFace, 2, PenStyle.DOT);

		switch(this._splitOrientation)
		{
			case SplitOrientation.VERTICAL:
			{
				c.drawEdge(Rect(this._splitPos, cr.top, SPLITTER_SIZE, cr.bottom), EdgeType.EDGE_RAISED, EdgeMode.LEFT | EdgeMode.RIGHT);

				for(int p = (this.height / 2) - 15, i = 0; i < 8; i++, p += 5)
				{
					c.drawLine(dp, mid, p, mid, p + 1);
					c.drawLine(lp, mid - 1, p - 1, mid - 1, p);
				}
			}
			break;

			default: // SplitOrientation.HORIZONTAL
			{
				c.drawEdge(Rect(cr.left, this._splitPos, cr.right, SPLITTER_SIZE), EdgeType.EDGE_RAISED, EdgeMode.TOP | EdgeMode.BOTTOM);

				for(int p = (this.width / 2) - 15, i = 0; i < 8; i++, p += 5)
				{
					c.drawLine(dp, p, mid, p + 1, mid);
					c.drawLine(lp, p - 1, mid + 1, p - 1, mid);
				}
			}
			break;
		}

		super.onPaint(e);
	}
}

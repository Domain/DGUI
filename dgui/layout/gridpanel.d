module dgui.layout.gridpanel;

import std.algorithm;
import dgui.core.interfaces.idisposable;
import dgui.layout.layoutcontrol;

class ColumnPart: IDisposable
{
	private Control _control;
	private GridPanel _gridPanel;
	private int _width = 0;
	private int _marginLeft = 0;
	private int _marginRight = 0;

	package this(GridPanel gp, Control c)
	{
		this._gridPanel = gp;
		this._control = c;
	}

	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._control)
		{
			this._control.dispose();
			this._control = null;
		}
	}

	@property public int marginLeft()
	{
		return this._marginLeft;
	}

	@property public void marginLeft(int m)
	{
		this._marginLeft = m;
	}

	@property public int marginRight()
	{
		return this._marginRight;
	}

	@property public void marginRight(int m)
	{
		this._marginRight= m;
	}

	@property public int width()
	{
		return this._width;
	}

	@property public void width(int w)
	{
		this._width = w;

		if(this._gridPanel && this._gridPanel.created)
		{
			this._gridPanel.updateLayout();
		}
	}

	@property public GridPanel gridPanel()
	{
		return this._gridPanel;
	}

	@property public Control control()
	{
		return this._control;
	}
}

class RowPart: IDisposable
{
	private Collection!(ColumnPart) _columns;
	private GridPanel _gridPanel;
	private int _height = 0;
	private int _marginTop = 0;
	private int _marginBottom = 0;

	package this(GridPanel gp)
	{
		this._gridPanel = gp;
	}

	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._columns)
		{
			foreach(ColumnPart cp; this._columns)
			{
				cp.dispose();
			}

			this._columns.clear();
		}
	}

	@property public int marginTop()
	{
		return this._marginTop;
	}

	@property public void marginTop(int m)
	{
		this._marginTop = m;
	}

	@property public int marginBottom()
	{
		return this._marginBottom;
	}

	@property public void marginBottom(int m)
	{
		this._marginBottom = m;
	}

	@property public int height()
	{
		return this._height;
	}

	@property public void height(int h)
	{
		this._height = h;

		if(this._gridPanel && this._gridPanel.created)
		{
			this._gridPanel.updateLayout();
		}
	}

	@property public GridPanel gridPanel()
	{
		return this._gridPanel;
	}

	public ColumnPart addColumn()
	{
		return this.addColumn(null);
	}

	public ColumnPart addColumn(Control c)
	{
		if(!this._columns)
		{
			this._columns = new Collection!(ColumnPart)();
		}

		if(c)
		{
			c.parent = this._gridPanel; //Set the parent
		}

		ColumnPart cp = new ColumnPart(this._gridPanel, c);
		this._columns.add(cp);

		if(c && this._gridPanel && this._gridPanel.created)
		{
			c.show(); // Layout is done by LayoutControl
		}

		return cp;
	}

	public void removeColumn(int idx)
	{
		ColumnPart c = this._columns[idx];

		this._columns.removeAt(idx);
		c.dispose();

		this._gridPanel.updateLayout(); //Recalculate layout
	}

	@property public ColumnPart[] columns()
	{
		if(this._columns)
		{
			return this._columns.get();
		}

		return null;
	}
}

class GridPanel: LayoutControl
{
	private Collection!(RowPart) _rows;

	public RowPart addRow()
	{
		if(!this._rows)
		{
			this._rows = new Collection!(RowPart)();
		}

		RowPart rp = new RowPart(this);
		this._rows.add(rp);

		return rp;
	}

	public void removeRow(int idx)
	{
		if(this._rows)
		{
			RowPart c = this._rows[idx];

			this._rows.removeAt(idx);
			c.dispose();
		}
	}

	@property public RowPart[] rows()
	{
		if(this._rows)
		{
			return this._rows.get();
		}

		return null;
	}

	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.ClassName = WC_DGRIDPANEL;
		ccp.DefaultCursor = SystemCursors.arrow;

		super.createControlParams(ccp);
	}

	public override void updateLayout()
	{
		if(this._rows)
		{
			int x = 0, y = 0;

			foreach(RowPart rp; this._rows)
			{
				x = 0; // This is a new Row
				int maxCtrlHeight = rp.height;

				if(rp.columns)
				{
					if(!maxCtrlHeight)
					{
						// Find the max height of Controls
						foreach(ColumnPart cp; rp.columns)
						{
							if(cp.control)
							{
								maxCtrlHeight = max(maxCtrlHeight, cp.control.height);
							}
						}
					}

					foreach(ColumnPart cp; rp.columns)
					{
						int w = cp.width;

						if(cp.control)
						{
							if(!w)
							{
								w = cp.control.width;
							}

							cp.control.bounds = Rect(cp.marginLeft + x, rp.marginTop + y, w, maxCtrlHeight);
						}

						x += w + cp.marginRight;
					}
				}

				y += maxCtrlHeight + rp.marginBottom;
			}
		}
	}
}

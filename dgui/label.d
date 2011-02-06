module dgui.label;

public import dgui.control;

private const string WC_STATIC = "STATIC";
private const string WC_DLABEL = "DLabel";

enum LabelDrawMode: ubyte
{
	NORMAL = 0,
	OWNER_DRAW = 1,
}

enum ContentAlignment: ubyte
{
	TOP_CENTER 	   = 0,
	TOP_LEFT       = 1,
	TOP_RIGHT	   = 2,
	BOTTOM_CENTER  = 4,
	BOTTOM_LEFT    = 8,
	BOTTOM_RIGHT   = 16,
	MIDDLE_CENTER  = 32,
	MIDDLE_LEFT    = 64,
	MIDDLE_RIGHT   = 128,
}

class Label: SubclassedControl
{
	private LabelDrawMode _drawMode = LabelDrawMode.NORMAL;
	private ContentAlignment _ca = ContentAlignment.MIDDLE_LEFT;

	public final LabelDrawMode drawMode()
	{
		return this._drawMode;
	}

	public final void drawMode(LabelDrawMode ldm)
	{
		this._drawMode = ldm;
	}

	public final ContentAlignment alignment()
	{
		return this._ca;
	}

	public final void alignment(ContentAlignment ca)
	{
		this._ca = ca;
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DLABEL;
		pcw.OldClassName = WC_STATIC;

		this.setStyle(ControlStyle.USER_PAINT | ControlStyle.NO_ERASE, true);
		super.preCreateWindow(pcw);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		super.onPaint(e);

		if(this._drawMode is LabelDrawMode.NORMAL)
		{
			Canvas c = e.canvas;
			Rect r = void; //Inizializzata da GetClientRect()
			GetClientRect(this._handle, &r.rect);

			scope StringFormat sf = new StringFormat();

			switch(this._ca)
			{
				case ContentAlignment.TOP_CENTER:
					sf.horizontalAlignment = StringAlignment.CENTER;
					sf.verticalAlignment = StringAlignment.NEAR;
					break;

				case ContentAlignment.TOP_LEFT:
					sf.horizontalAlignment = StringAlignment.NEAR;
					sf.verticalAlignment = StringAlignment.NEAR;
					break;

				case ContentAlignment.TOP_RIGHT:
					sf.horizontalAlignment = StringAlignment.FAR;
					sf.verticalAlignment = StringAlignment.NEAR;
					break;

				case ContentAlignment.BOTTOM_CENTER:
					sf.horizontalAlignment = StringAlignment.CENTER;
					sf.verticalAlignment = StringAlignment.FAR;
					break;

				case ContentAlignment.BOTTOM_LEFT:
					sf.horizontalAlignment = StringAlignment.NEAR;
					sf.verticalAlignment = StringAlignment.FAR;
					break;

				case ContentAlignment.BOTTOM_RIGHT:
					sf.horizontalAlignment = StringAlignment.FAR;
					sf.verticalAlignment = StringAlignment.FAR;
					break;

				case ContentAlignment.MIDDLE_CENTER:
					sf.horizontalAlignment = StringAlignment.CENTER;
					sf.verticalAlignment = StringAlignment.CENTER;
					break;

				case ContentAlignment.MIDDLE_LEFT:
					sf.horizontalAlignment = StringAlignment.NEAR;
					sf.verticalAlignment = StringAlignment.CENTER;
					break;

				case ContentAlignment.MIDDLE_RIGHT:
					sf.horizontalAlignment = StringAlignment.FAR;
					sf.verticalAlignment = StringAlignment.CENTER;
					break;

				default:
					break;
			}

			scope SolidBrush bc = new SolidBrush(this._controlInfo.BackColor);
			scope SolidBrush fc = new SolidBrush(this._controlInfo.ForeColor);

			c.fillRectangle(bc, r);
			c.drawString(this.text, r, fc, this.font, sf);
		}
	}
}

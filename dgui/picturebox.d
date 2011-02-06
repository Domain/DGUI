module dgui.picturebox;

public import dgui.control;
public import dgui.canvas;

private const string WC_DPICTUREBOX = "DPicturebox";

enum SizeMode
{
	NORMAL = 0,
	AUTO_SIZE = 1,
}

class PictureBox: Control
{
	private SizeMode _sm = SizeMode.NORMAL;
	private Image _img;

	public override void dispose()
	{
		if(this._img)
		{
			this._img.dispose();
			this._img = null;
		}

		super.dispose();
	}

	alias Control.bounds bounds;

	public override void bounds(Rect r)
	{
		if(this._img && this._sm is SizeMode.AUTO_SIZE)
		{
			// Ignora 'r.size' e usa la dimensione dell'immagine
			Size sz = r.size;
			super.bounds = Rect(r.x, r.y, sz.width, sz.height);

		}
		else
		{
			super.bounds = r;
		}
	}

	public final SizeMode sizeMode()
	{
		return this._sm;
	}

	public final void sizeMode(SizeMode sm)
	{
		this._sm = sm;

		if(this.created)
		{
			this.redraw();
		}
	}

	public final Image image()
	{
		return this._img;
	}

	public final void image(Image img)
	{
		if(this._img)
		{
			this._img.dispose(); //Distruggo l'immagine precedente
		}

		this._img = img;

		if(this.created)
		{
			this.redraw();
		}
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.ClassName  = WC_DPICTUREBOX;
		pcw.DefaultCursor = SystemCursors.arrow;

		this._controlInfo.CStyle |= ControlStyle.NO_ERASE;

		super.preCreateWindow(pcw);
	}

	protected override void onPaint(PaintEventArgs e)
	{
		if(this._img)
		{
			Canvas c = e.canvas;

			switch(this._sm)
			{
				case SizeMode.AUTO_SIZE:
					c.drawImage(this._img, this.bounds);
					break;

				default:
					c.drawImage(this._img, NullPoint);
					break;
			}
		}

		super.onPaint(e);
	}
}

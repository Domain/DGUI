module dgui.imagelist;

public import dgui.core.winapi;
public import dgui.core.collection;
public import dgui.canvas;

enum ColorDepth: uint
{
	DEPTH_4BIT = ILC_COLOR4,
	DEPTH_8BIT = ILC_COLOR8,
	DEPTH_16BIT = ILC_COLOR16,
	DEPTH_24BIT = ILC_COLOR24,
	DEPTH_32BIT = ILC_COLOR32,
}

alias extern(Windows) HIMAGELIST function(int, int, uint, int, int) ImageList_CreateProc;
alias extern(Windows) BOOL function(HIMAGELIST, int) ImageList_RemoveProc;
alias extern(Windows) int function(HIMAGELIST, HICON) ImageList_AddIconProc;

class ImageList: Handle!(HIMAGELIST), IDisposable
{
	private static ImageList_CreateProc imageList_Create;
	private static ImageList_RemoveProc imageList_Remove;
	private static ImageList_AddIconProc imageList_AddIcon;

	private ColorDepth _depth = ColorDepth.DEPTH_32BIT;
	private Size _size;
	private Collection!(Icon) _images;

	public this()
	{
		if(!imageList_Create)
		{
			HMODULE hModule = LoadLibraryA(toStringz("comctl32.dll")); //FIXME: Perche' non GetModuleHandle ?

			/*
			 * Problema Librerie Statiche, si risolve col binding dinamico: Abilita i Visual Styles, se supportati.
			 * (Vedi ToolBar con Manifest per i risultati)
			 */

			imageList_Create = cast(ImageList_CreateProc)GetProcAddress(hModule, "ImageList_Create");
			imageList_Remove = cast(ImageList_RemoveProc)GetProcAddress(hModule, "ImageList_Remove");
			imageList_AddIcon = cast(ImageList_AddIconProc)GetProcAddress(hModule, "ImageList_AddIcon");
		}
	}

	public ~this()
	{
		if(this.created)
		{
			this.dispose();
		}
	}

	public void dispose()
	{
		ImageList_Destroy(this._handle);
	}

	public final void drawIcon(int i, Canvas dest, Point pos)
	{
		HDC hdc = dest.getHDC();
		ImageList_Draw(this._handle, i, hdc, pos.x, pos.y, ILD_NORMAL);
		dest.releaseDC();
	}

	public final int addImage(Icon ico)
	{
		if(!this._images)
		{
			this._images = new Collection!(Icon)();
		}

		this._images.add(ico);

		if(!this.created)
		{
			if(this._size == NullSize)
			{
				this._size.width = 16;
				this._size.height = 16;
			}

			this._handle = imageList_Create(this._size.width, this._size.height, this._depth | ILC_MASK, 0, 0);
			ImageList_SetBkColor(this._handle, CLR_NONE);
		}

		return imageList_AddIcon(this._handle, ico.handle);
	}

	public final void removeImage(int index)
	{
		if(this._images)
		{
			this._images.removeAt(index);
		}

		if(this.created)
		{
			imageList_Remove(this._handle, index);
		}
	}

	public final void clear()
	{
		imageList_Remove(this._handle, -1);
	}

	public final Collection!(Icon) images()
	{
		return this._images;
	}

	public final Size size()
	{
		return this._size;
	}

	public final void size(Size sz)
	{
		this._size = sz;
	}

	public final ColorDepth colorDepth()
	{
		return this._depth;
	}

	public final void colorDepth(ColorDepth depth)
	{
		this._depth = depth;
	}
}

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

/*
 * Dynamic Binding (Uses The Latest Version Available)
 */

alias extern(Windows) HIMAGELIST function(int, int, uint, int, int) ImageList_CreateProc;
alias extern(Windows) HIMAGELIST function(HIMAGELIST) ImageList_DestroyProc;
alias extern(Windows) BOOL function(HIMAGELIST, int) ImageList_RemoveProc;
alias extern(Windows) int function(HIMAGELIST, HICON) ImageList_AddIconProc;
alias extern(Windows) int function(HIMAGELIST, int, HDC, int, int, UINT) ImageList_DrawProc;
alias extern(Windows) int function(HIMAGELIST, COLORREF) ImageList_SetBkColorProc;

class ImageList: Handle!(HIMAGELIST), IDisposable
{
	private static ImageList_CreateProc imageList_Create;
	private static ImageList_RemoveProc imageList_Remove;
	private static ImageList_AddIconProc imageList_AddIcon;
	private static ImageList_DestroyProc imageList_Destroy;
	private static ImageList_DrawProc imageList_Draw;
	private static ImageList_SetBkColorProc imageList_SetBkColor;

	private ColorDepth _depth = ColorDepth.DEPTH_32BIT;
	private Size _size;
	private Collection!(Icon) _images;

	public this()
	{
		if(!imageList_Create)
		{
			HMODULE hModule = GetModuleHandleA("comctl32.dll");

			/*
			 * Problema Librerie Statiche, si risolve col binding dinamico: Abilita i Visual Styles, se supportati.
			 * (Vedi ToolBar con Manifest per i risultati)
			 */

			imageList_Create = cast(ImageList_CreateProc)GetProcAddress(hModule, "ImageList_Create");
			imageList_Remove = cast(ImageList_RemoveProc)GetProcAddress(hModule, "ImageList_Remove");
			imageList_AddIcon = cast(ImageList_AddIconProc)GetProcAddress(hModule, "ImageList_AddIcon");
			imageList_Destroy = cast(ImageList_DestroyProc)GetProcAddress(hModule, "ImageList_Destroy");
			imageList_Draw = cast(ImageList_DrawProc)GetProcAddress(hModule, "ImageList_Draw");
			imageList_SetBkColor = cast(ImageList_SetBkColorProc)GetProcAddress(hModule, "ImageList_SetBkColor");
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
		imageList_Destroy(this._handle);
	}

	public final void drawIcon(int i, Canvas dest, Point pos)
	{
		imageList_Draw(this._handle, i, dest.handle, pos.x, pos.y, ILD_NORMAL);
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
			imageList_SetBkColor(this._handle, CLR_NONE);
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

	@property public final Collection!(Icon) images()
	{
		return this._images;
	}

	@property public final Size size()
	{
		return this._size;
	}

	@property public final void size(Size sz)
	{
		this._size = sz;
	}

	@property public final ColorDepth colorDepth()
	{
		return this._depth;
	}

	@property public final void colorDepth(ColorDepth depth)
	{
		this._depth = depth;
	}
}

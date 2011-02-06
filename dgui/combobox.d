module dgui.combobox;

public import utf = std.utf;
public import dgui.imagelist;
public import dgui.control;

private const string WC_COMBOBOXEX = "ComboBoxEx32";
private const string WC_DCOMBOBOX = "DComboBox";

enum DropDownStyles: uint
{
	SIMPLE = CBS_SIMPLE,
	DROPDOWN = CBS_DROPDOWN,
	DROPDOWN_LIST = CBS_DROPDOWNLIST,
}

struct ComboInfo
{
	int SelectedIndex;
	ImageList ImgList;
	DropDownStyles DDStyle = DropDownStyles.DROPDOWN;
}

class ComboBoxItem
{
	private ComboBox _owner;
	private string _text;
	private int _imgIndex;
	private Object _tag;
	private int _idx;

	package this(string txt, int idx = -1)
	{
		this._text = txt;
		this._imgIndex = idx;
	}

	public final int index()
	{
		return this._idx;
	}

	package void index(int idx)
	{
		this._idx = idx;
	}

	public final ComboBox comboBox()
	{
		return this._owner;
	}

	package void comboBox(ComboBox cbx)
	{
		this._owner = cbx;
	}

	public final int imageIndex()
	{
		return this._imgIndex;
	}

	public final void imageIndex(int idx)
	{
		this._imgIndex = idx;

		if(this._owner && this._owner.created)
		{
			COMBOBOXEXITEMA cbei;

			cbei.mask = CBEIF_IMAGE;
			cbei.iImage = idx;
			cbei.iItem = this._idx;

			this._owner.sendMessage(CBEM_SETITEMA, 0, cast(LPARAM)&cbei);
		}
	}

	public final string text()
	{
		return this._text;
	}

	public final void text(string txt)
	{
		this._text = txt;

		if(this._owner && this._owner.created)
		{
			COMBOBOXEXITEMA cbei;

			cbei.mask = CBEIF_TEXT;
			cbei.pszText = toStringz(txt);
			cbei.iItem = this._idx;

			this._owner.sendMessage(CBEM_SETITEMA, 0, cast(LPARAM)&cbei);
		}
	}

	public final Object tag()
	{
		return this._tag;
	}

	public final void tag(Object obj)
	{
		this._tag = obj;
	}
}

class ComboBox: SubclassedControl
{
	public Signal!(Control, EventArgs) itemChanged;

	private Collection!(ComboBoxItem) _items;
	private ComboInfo _cbxInfo;

	public this()
	{
		super();

		this.setStyle(DropDownStyles.DROPDOWN, true);
	}

	public final ComboBoxItem addItem(string s, int imgIndex = -1)
	{
		if(!this._items)
		{
			this._items = new Collection!(ComboBoxItem)();
		}

		ComboBoxItem cbi = new ComboBoxItem(s, imgIndex);
		this._items.add(cbi);

		if(this.created)
		{
			return this.insertItem(cbi);
		}

		return cbi;
	}

	public final void removeItem(int idx)
	{
		if(this.created)
		{
			this.sendMessage(CB_DELETESTRING, idx, 0);
		}

		this._items.removeAt(idx);
	}

	public final int selectedIndex()
	{
		if(this.created)
		{
			return this.sendMessage(CB_GETCURSEL, 0, 0);
		}

		return this._cbxInfo.SelectedIndex;
	}

	public final void selectedIndex(int i)
	{
		this._cbxInfo.SelectedIndex = i;

		if(this.created)
		{
			this.sendMessage(CB_SETCURSEL, i, 0);
		}
	}

	public void clear()
	{
		if(this._items)
		{
			foreach(ComboBoxItem cbi; this._items)
			{
				this.sendMessage(CB_DELETESTRING, 0, 0);
			}

			this._items.clear();
		}

		this.selectedIndex = -1;
	}

	public final ComboBoxItem selectedItem()
	{
		if(this.created)
		{
			return this._items[this._cbxInfo.SelectedIndex];
		}
		else
		{
			int idx = this.selectedIndex;

			if(this._items)
			{
				return this._items[idx];
			}
		}

		return null;
	}

	public final ImageList imageList()
	{
		return this._cbxInfo.ImgList;
	}

	public void imageList(ImageList imgList)
	{
		this._cbxInfo.ImgList = imgList;

		if(this.created)
		{
			this.sendMessage(CBEM_SETIMAGELIST, 0, cast(LPARAM)this._cbxInfo.ImgList.handle);
		}
	}

	public final void dropDownStyle(DropDownStyles dds)
	{
		if(dds !is this._cbxInfo.DDStyle)
		{
			this.setStyle(this._cbxInfo.DDStyle, false); //Rimuovo il vecchio
			this.setStyle(dds, true); //Aggiungo il nuovo
			this._cbxInfo.DDStyle = dds; //Salvo il nuovo
		}
	}

	public final Collection!(ComboBoxItem) items()
	{
		return this._items;
	}

	private ComboBoxItem insertItem(ComboBoxItem cbi)
	{
		COMBOBOXEXITEMA cbei;

		cbei.mask = CBEIF_TEXT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_LPARAM;
		cbei.iItem = -1;
		cbei.iImage = cbi.imageIndex;
		cbei.iSelectedImage = cbi.imageIndex;
		cbei.pszText = toStringz(cbi.text);
		cbei.lParam = winCast!(LPARAM)(cbi);

		cbi.index = this.sendMessage(CBEM_INSERTITEMA, 0, cast(LPARAM)&cbei);
		cbi.comboBox = this;
		return cbi;
	}

	protected void onItemChanged(EventArgs e)
	{
		this.itemChanged(this, e);
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_COMBOBOXEX;
		pcw.ClassName = WC_DCOMBOBOX;

		if(!this.height)
		{
			this.height = this.topLevelControl.height;
		}

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._cbxInfo.ImgList)
		{
			this.sendMessage(CBEM_SETIMAGELIST, 0, cast(LPARAM)this._cbxInfo.ImgList.handle);
		}

		if(this._items)
		{
			foreach(ComboBoxItem cbi; this._items)
			{
				this.insertItem(cbi);
			}
		}

		if(this._cbxInfo.SelectedIndex != -1)
		{
			this.selectedIndex = this._cbxInfo.SelectedIndex;
		}

		super.onHandleCreated(e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_COMMAND:
			{
				switch(HIWORD(wParam))
				{
					case CBN_SELCHANGE:
						this._cbxInfo.SelectedIndex = this.sendMessage(CB_GETCURSEL, 0, 0);
						this.onItemChanged(EventArgs.empty);
						break;

					default:
						break;
				}
			}

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}
}

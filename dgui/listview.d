module dgui.listview;

public import dgui.control;
public import dgui.imagelist;

private const string WC_LISTVIEW = "SysListView32";
private const string WC_DLISTVIEW = "DListView";

enum ColumnTextAlign: int
{
	LEFT = LVCFMT_LEFT,
	CENTER = LVCFMT_CENTER,
	RIGHT = LVCFMT_RIGHT,
}

enum ViewStyle: uint
{
	LIST = LVS_LIST,
	REPORT = LVS_REPORT,
	LARGE_ICON = LVS_ICON,
	SMALL_ICON = LVS_SMALLICON,
}

private struct ListViewInfo
{
	ListViewItem SelectedItem;
	ImageList ImgList;
	bool GridLines = false;
	bool FullRow = false;
	bool CheckBoxes = false;
}

class ListViewItem
{
	private Collection!(ListViewItem) _subItems;
	private bool _checked = false;
	private ListViewItem _parentItem;
	private ListView _owner;
	private string _text;
	private int _imgIdx;
	private Object _tag;

	package this(ListView owner, string txt, int imgIdx, bool check)
	{
		this._checked = check;
		this._imgIdx = imgIdx;
		this._owner = owner;
		this._text = txt;
	}

	package this(ListView owner, ListViewItem parentItem, string txt, int imgIdx, bool check)
	{
		this._parentItem = parentItem;
		this(owner, txt, imgIdx, check);
	}

	public final int index()
	{
		if(this._owner)
		{
			int i = 0;

			foreach(ListViewItem lvi; this._owner.items)
			{
				if(lvi is (this._parentItem ? this._parentItem : this))
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	public final int imageIndex()
	{
		return this._imgIdx;
	}

	public final void imageIndex(int imgIdx)
	{
		if(this._parentItem)
		{
			return;
		}

		this._imgIdx = imgIdx;

		if(this._owner && this._owner.created)
		{
			LVITEMA lvi;

			lvi.mask = LVIF_IMAGE;
			lvi.iItem = this.index;
			lvi.iSubItem = 0;
			lvi.iImage = imgIdx;

			this._owner.sendMessage(LVM_SETITEMA, 0, cast(LPARAM)&lvi);
		}
	}

	public final string text()
	{
		return this._text;
	}

	public final void text(string s)
	{
		this._text = s;

		if(this._owner && this._owner.created)
		{
			LVITEMA lvi;

			lvi.mask = LVIF_TEXT;
			lvi.iItem = this.index;
			lvi.iSubItem = !this._parentItem ? 0 : this.subitemIndex;
			lvi.pszText = toStringz(s);

			this._owner.sendMessage(LVM_SETITEMA, 0, cast(LPARAM)&lvi);
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

	package bool internalChecked() //HACK: Restituisce il flag interno
	{
		return this._checked;
	}

	public final bool checked()
	{
		if(this._owner && this._owner.created)
		{
			return cast(bool)((this._owner.sendMessage(LVM_GETITEMSTATE, this.index, LVIS_STATEIMAGEMASK) >> 12) - 1);
		}

		return this._checked;
	}

	public final void checked(bool b)
	{
		if(this._parentItem)
		{
			return;
		}

		this._checked = b;

		if(this._owner && this._owner.created)
		{
			LVITEMA lvi;

			lvi.mask = LVIF_STATE;
			lvi.stateMask = LVIS_STATEIMAGEMASK;
			lvi.state = cast(LPARAM)(b ? 2 : 1) << 12; //Checked State

			this._owner.sendMessage(LVM_SETITEMSTATE, this.index, cast(LPARAM)&lvi);
		}
	}

	public final void addSubItem(string txt)
	{
		if(this._parentItem) //E' un subitem, non fare niente.
		{
			return;
		}

		if(!this._subItems)
		{
			this._subItems = new Collection!(ListViewItem)();
		}

		ListViewItem lvi = new ListViewItem(this._owner, this, txt, -1, false);
		this._subItems.add(lvi);

		if(this._owner && this._owner.created)
		{
			ListView.insertItem(lvi, true);
		}
	}

	public final Collection!(ListViewItem) subItems()
	{
		return this._subItems;
	}

	public final ListView listView()
	{
		return this._owner;
	}

	package ListViewItem parentItem()
	{
		return this._parentItem;
	}

	package void removeSubItem(int idx)
	{
		this._subItems.removeAt(idx);
	}

	package int subitemIndex()
	{
		if(this._parentItem is this)
		{
			return 0; //Se è l'item principale ritorna 0.
		}
		else if(!this._parentItem.subItems)
		{
			return 1; //E' il primo subitem
		}
		else if(this._owner && this._parentItem)
		{
			int i = 0;

			foreach(ListViewItem lvi; this._parentItem.subItems)
			{
				if(lvi is this)
				{
					return i + 1;
				}

				i++;
			}
		}

		return -1; //Non dovrebbe mai restituire -1
	}
}

class ListViewColumn
{
	private ColumnTextAlign _cta;
	private ListView _owner;
	private string _text;
	private int _width;

	package this(ListView owner, string txt, int w, ColumnTextAlign cta)
	{
		this._owner = owner;
		this._text = txt;
		this._width = w;
		this._cta = cta;
	}

	public int index()
	{
		if(this._owner)
		{
			int i = 0;

			foreach(ListViewColumn lvc; this._owner.columns)
			{
				if(lvc is this)
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	public string text()
	{
		return this._text;
	}

	public int width()
	{
		return this._width;
	}

	public ColumnTextAlign textAlign()
	{
		return this._cta;
	}

	public ListView listView()
	{
		return this._owner;
	}
}

public alias ItemCheckedEventArgs!(ListViewItem) ListViewItemCheckedEventArgs;

class ListView: OwnerDrawControl
{
	public Signal!(Control, EventArgs) itemChanged;
	public Signal!(Control, ListViewItemCheckedEventArgs) itemChecked;

	private Collection!(ListViewColumn) _columns;
	private Collection!(ListViewItem) _items;
	private ListViewInfo _lvwInfo;

	public this()
	{
		super();

		this.setStyle(LVS_ALIGNTOP | LVS_AUTOARRANGE | LVS_SHAREIMAGELISTS, true);
	}

	public final ImageList imageList()
	{
		return this._lvwInfo.ImgList;
	}

	public final void imageList(ImageList imgList)
	{
		 this._lvwInfo.ImgList = imgList;

		if(this.created)
		{
			this.sendMessage(LVM_SETIMAGELIST, LVSIL_NORMAL, cast(LPARAM)imgList.handle);
			this.sendMessage(LVM_SETIMAGELIST, LVSIL_SMALL, cast(LPARAM)imgList.handle);
		}
	}

	public final ViewStyle viewStyle()
	{
		if(this.getStyle() & ViewStyle.LARGE_ICON)
		{
			return ViewStyle.LARGE_ICON;
		}
		else if(this.getStyle & ViewStyle.SMALL_ICON)
		{
			return ViewStyle.SMALL_ICON;
		}
		else if(this.getStyle & ViewStyle.LIST)
		{
			return ViewStyle.LIST;
		}
		else if(this.getStyle & ViewStyle.REPORT)
		{
			return ViewStyle.REPORT;
		}

		assert(false, "Unknwown ListView Style");
	}

	public final void viewStyle(ViewStyle vs)
	{
		this.setStyle(vs, true);
	}

	public final bool fullRow()
	{
		return this._lvwInfo.FullRow;
	}

	public final void fullRow(bool b)
	{
		this._lvwInfo.FullRow = b;

		if(this.created)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_FULLROWSELECT, b ? LVS_EX_FULLROWSELECT : 0);
		}
	}

	public final bool gridLines()
	{
		return this._lvwInfo.GridLines;
	}

	public final void gridLines(bool b)
	{
		this._lvwInfo.GridLines = b;

		if(this.created)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_GRIDLINES, b ? LVS_EX_GRIDLINES : 0);
		}
	}

	public final bool checkBoxes()
	{
		return this._lvwInfo.CheckBoxes;
	}

	public final void checkBoxes(bool b)
	{
		this._lvwInfo.CheckBoxes = b;

		if(this.created)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_CHECKBOXES, b ? LVS_EX_CHECKBOXES : 0);
		}
	}

	public final ListViewItem selectedItem()
	in
	{
		assert(this.created);
	}
	body
	{
		return this._lvwInfo.SelectedItem;
	}

	public final ListViewColumn addColumn(string txt, int w, ColumnTextAlign cta = ColumnTextAlign.LEFT)
	{
		if(!this._columns)
		{
			this._columns = new Collection!(ListViewColumn)();
		}

		ListViewColumn lvc = new ListViewColumn(this, txt, w, cta);
		this._columns.add(lvc);

		if(this.created)
		{
			ListView.insertColumn(lvc);
		}

		return lvc;
	}

	public final void removeColumn(int idx)
	{
		this._columns.removeAt(idx);

		/*
		 * Rimuovo tutti gli items nella colonna rimossa
		 */

		if(this._items)
		{
			if(idx)
			{
				foreach(ListViewItem lvi; this._items)
				{
					lvi.removeSubItem(idx - 1); //Subitems iniziano da 0 nelle DGui e da 1 su Windows.
				}
			}
			else
			{
				//TODO: Gestire caso "Rimozione colonna 0".
			}
		}

		if(this.created)
		{
			this.sendMessage(LVM_DELETECOLUMN, idx, 0);
		}
	}

	public final ListViewItem addItem(string txt, int imgIdx = -1, bool checked = false)
	{
		if(!this._items)
		{
			this._items = new Collection!(ListViewItem)();
		}

		ListViewItem lvi = new ListViewItem(this, txt, imgIdx, checked);
		this._items.add(lvi);

		if(this.created)
		{
			ListView.insertItem(lvi);
		}

		return lvi;
	}

	public final void removeItem(int idx)
	{
		if(this._items)
		{
			this._items.removeAt(idx);
		}

		if(this.created)
		{
			this.sendMessage(LVM_DELETEITEM, idx, 0);
		}
	}

	public final void clear()
	{
		if(this._items)
		{
			this._items.clear();
		}

		if(this.created)
		{
			this.sendMessage(LVM_DELETEALLITEMS, 0, 0);
		}
	}

	public final Collection!(ListViewItem) items()
	{
		return this._items;
	}

	public final Collection!(ListViewColumn) columns()
	{
		return this._columns;
	}

	package static void insertItem(ListViewItem item, bool subitem = false)
	{
		/*
		 * Item: Item (o SubItem) da inserire.
		 * Subitem = E' un SubItem?
		 */

		int idx = item.index;
		LVITEMA lvi;

		lvi.mask = LVIF_TEXT | (!subitem ? (LVIF_IMAGE | LVIF_STATE | LVIF_PARAM) : 0);
		lvi.iImage = !subitem ? item.imageIndex : -1;
		lvi.iItem = !subitem ? idx : item.parentItem.index;
		lvi.iSubItem = !subitem ? 0 : item.subitemIndex; //Per windows il subitem inizia da 1 (lo 0 e' l'item principale).
		lvi.pszText = toStringz(item.text);
		lvi.lParam = winCast!(LPARAM)(item);

		item.listView.sendMessage(!subitem ? LVM_INSERTITEMA : LVM_SETITEMA, 0, cast(LPARAM)&lvi);

		if(!subitem)
		{
			if(item.listView.checkBoxes) //LVM_INSERTITEM non gestisce i checkbox, uso LVM_SETITEMSTATE
			{
				//Riciclo la variabile 'lvi'

				lvi.mask = LVIF_STATE;
				lvi.stateMask = LVIS_STATEIMAGEMASK;
				lvi.state = cast(LPARAM)(item.internalChecked ? 2 : 1) << 12; //Checked State
				item.listView.sendMessage(LVM_SETITEMSTATE, idx, cast(LPARAM)&lvi);
			}

			Collection!(ListViewItem) subItems = item.subItems;

			if(subItems)
			{
				foreach(ListViewItem slvi; subItems)
				{
					ListView.insertItem(slvi, true);
				}
			}
		}
	}

	private static void insertColumn(ListViewColumn col)
	{
		LVCOLUMNA lvc;

		lvc.mask =  LVCF_TEXT | LVCF_WIDTH | LVCF_FMT;
		lvc.cx = col.width;
		lvc.fmt = col.textAlign;
		lvc.pszText = toStringz(col.text);

		col.listView.sendMessage(LVM_INSERTCOLUMNA, col.listView._columns.length, cast(LPARAM)&lvc);
	}

	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_LISTVIEW;
		pcw.ClassName = WC_DLISTVIEW;
		pcw.DefaultBackColor = SystemColors.colorWindow;

		super.preCreateWindow(pcw);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		switch(msg)
		{
			case WM_NOTIFY:
			{
				NMLISTVIEW* pNotify = cast(NMLISTVIEW*)lParam;

				if(pNotify && pNotify.iItem != -1)
				{
					switch(pNotify.hdr.code)
					{
						case LVN_ITEMCHANGED:
						{
							if(pNotify.uChanged & LVIF_STATE)
							{
								uint changedState = pNotify.uNewState ^ pNotify.uOldState;

								if(pNotify.uNewState & LVIS_SELECTED)
								{
									this._lvwInfo.SelectedItem = this._items[pNotify.iItem];
									this.onSelectedItemChanged(EventArgs.empty);
								}

								if((changedState & 0x2000) || (changedState & 0x1000)) /* IF Checked || Unchecked THEN */
								{
									scope ListViewItemCheckedEventArgs e = new ListViewItemCheckedEventArgs(this._items[pNotify.iItem]);
									this.onItemChecked(e);
								}
							}
						}
						break;

						default:
							break;
					}
				}
			}
			break;

			default:
				break;
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._lvwInfo.GridLines)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_GRIDLINES, LVS_EX_GRIDLINES);
		}

		if(this._lvwInfo.FullRow)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_FULLROWSELECT, LVS_EX_FULLROWSELECT);
		}

		if(this._lvwInfo.CheckBoxes)
		{
			this.sendMessage(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_CHECKBOXES, LVS_EX_CHECKBOXES);
		}

		if(this._lvwInfo.ImgList)
		{
			this.sendMessage(LVM_SETIMAGELIST, LVSIL_NORMAL, cast(LPARAM)this._lvwInfo.ImgList.handle);
			this.sendMessage(LVM_SETIMAGELIST, LVSIL_SMALL, cast(LPARAM)this._lvwInfo.ImgList.handle);
		}

		if(this.getStyle() & ViewStyle.REPORT)
		{
			if(this._columns)
			{
				foreach(ListViewColumn lvc; this._columns)
				{
					ListView.insertColumn(lvc);
				}
			}
		}

		if(this._items)
		{
			foreach(ListViewItem lvi; this._items)
			{
				ListView.insertItem(lvi);
			}
		}

		super.onHandleCreated(e);
	}

	protected void onSelectedItemChanged(EventArgs e)
	{
		this.itemChanged(this, e);
	}

	protected void onItemChecked(ListViewItemCheckedEventArgs e)
	{
		this.itemChecked(this, e);
	}
}

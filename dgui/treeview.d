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

module dgui.treeview;

import std.utf: toUTF16z;
import dgui.core.utils;
import dgui.control;
import dgui.imagelist;

class TreeNode: Handle!(HTREEITEM)//, IDisposable
{
	private Collection!(TreeNode) _nodes;
	private TreeView _owner;
	private TreeNode _parent;
	private string _text;
	private int _imgIndex;
	private int _selImgIndex;
	private Object _tag;

	package this(TreeView owner, string txt, int imgIndex, int selImgIndex)
	{
		this._owner = owner;
		this._text = txt;
		this._imgIndex = imgIndex;
		this._selImgIndex = selImgIndex;
	}

	package this(TreeView owner, TreeNode parent, string txt, int imgIndex, int selImgIndex)
	{
		this._parent = parent;
		this(owner, txt, imgIndex, selImgIndex);
	}

	/*
	public ~this()
	{
		this.dispose();
	}

	public void dispose()
	{
		if(this._nodes)
		{
			this._nodes.clear();
		}

		this._owner = null;
		this._handle = null;
		this._parent = null;
	}
	*/

	public final TreeNode addNode(string txt, int imgIndex = -1, int selImgIndex = -1)
	{
		if(!this._nodes)
		{
			this._nodes = new Collection!(TreeNode)();
		}

		TreeNode tn = new TreeNode(this._owner, this, txt, imgIndex, selImgIndex == -1 ? imgIndex : selImgIndex);
		this._nodes.add(tn);

		if(this._owner && this._owner.created)
		{
			TreeView.createTreeNode(tn);
		}

		return tn;
	}

	public final void removeNode(TreeNode node)
	{
		if(this.created)
		{
			TreeView.removeTreeNode(node);
		}

		if(this._nodes)
		{
			this._nodes.remove(node);
		}
	}

	public final void removeNode(int idx)
	{
		TreeNode node = null;

		if(this._nodes)
		{
			node = this._nodes[idx];
		}

		if(node)
		{
			TreeView.removeTreeNode(node);
		}
	}

	public final void remove()
	{
		TreeView.removeTreeNode(this);
	}

	@property public final TreeView treeView()
	{
		return this._owner;
	}

	@property public final TreeNode parentNode()
	{
		return this._parent;
	}

	@property public final bool selected()
	{
		if(this._owner && this._owner.created)
		{
			TVITEMW tvi = void;

			tvi.mask = TVIF_STATE | TVIF_HANDLE;
			tvi.hItem = this._handle;
			tvi.stateMask = TVIS_SELECTED;

			this._owner.sendMessage(TVM_GETITEMW, 0, cast(LPARAM)&tvi);
			return (tvi.state & TVIS_SELECTED) ? true : false;
		}

		return false;
	}

	@property public final Object tag()
	{
		return this._tag;
	}

	@property public final void tag(Object obj)
	{
		this._tag = obj;
	}

	@property public final string text()
	{
		return this._text;
	}

	@property public final void text(string txt)
	{
		this._text = txt;

		if(this._owner && this._owner.created)
		{
			TVITEMW tvi = void;

			tvi.mask = TVIF_TEXT | TVIF_HANDLE;
			tvi.hItem = this._handle;
			tvi.pszText = toUTF16z(txt);
			this._owner.sendMessage(TVM_SETITEMW, 0, cast(LPARAM)&tvi);
		}
	}

	@property public final int imageIndex()
	{
		return this._imgIndex;
	}

	@property public final void imageIndex(int idx)
	{
		this._imgIndex = idx;

		if(this._owner && this._owner.created)
		{
			TVITEMW tvi = void;

			tvi.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_HANDLE;
			tvi.hItem = this._handle;
			this._owner.sendMessage(TVM_GETITEMW, 0, cast(LPARAM)&tvi);

			if(tvi.iSelectedImage == tvi.iImage) //Non e' mai stata assegnata veramente, quindi SelectedImage = Image.
			{
				tvi.iSelectedImage = idx;
			}

			tvi.iImage = idx;
			this._owner.sendMessage(TVM_SETITEMW, 0, cast(LPARAM)&tvi);
		}
	}

	@property public final int selectedImageIndex()
	{
		return this._selImgIndex;
	}

	@property public final void selectedImageIndex(int idx)
	{
		this._selImgIndex = idx;

		if(this._owner && this._owner.created)
		{
			TVITEMW tvi = void;

			tvi.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_HANDLE;
			tvi.hItem = this._handle;
			this._owner.sendMessage(TVM_GETITEMW, 0, cast(LPARAM)&tvi);

			idx == -1 ? (tvi.iSelectedImage = tvi.iImage) : (tvi.iSelectedImage = idx);
			this._owner.sendMessage(TVM_SETITEMW, 0, cast(LPARAM)&tvi);
		}
	}

	@property public final TreeNode[] nodes()
	{
		if(this._nodes)
		{
			return this._nodes.get();
		}

		return null;
	}

	public final void collapse()
	{
		if(this._owner && this._owner.createCanvas && this.created)
		{
			this._owner.sendMessage(TVM_EXPAND, TVE_COLLAPSE, cast(LPARAM)this._handle);
		}
	}

	public final void expand()
	{
		if(this._owner && this._owner.createCanvas && this.created)
		{
			this._owner.sendMessage(TVM_EXPAND, TVE_EXPAND, cast(LPARAM)this._handle);
		}
	}

	@property public final bool hasNodes()
	{
		return (this._nodes ? true : false);
	}

	@property public final int index()
	{
		if(this._parent && this._parent.hasNodes)
		{
			int i = 0;

			foreach(TreeNode node; this._parent.nodes)
			{
				if(node is this)
				{
					return i;
				}

				i++;
			}
		}

		return -1;
	}

	@property public override HTREEITEM handle()
	{
		return super.handle();
	}

	@property package void handle(HTREEITEM hTreeNode)
	{
		this._handle = hTreeNode;
	}

	package void doChildNodes()
	{
		if(this._nodes)
		{
			foreach(TreeNode tn; this._nodes)
			{
				TreeView.createTreeNode(tn);
			}
		}
	}
}

public alias ItemChangedEventArgs!(TreeNode) TreeNodeChangedEventArgs;

class TreeView: SubclassedControl
{
	public Signal!(Control, CancelEventArgs) selectedNodeChanging;
	public Signal!(Control, TreeNodeChangedEventArgs) selectedNodeChanged;

	private Collection!(TreeNode) _nodes;
	private ImageList _imgList;
	private TreeNode _selectedNode;

	public final void clear()
	{
		this.sendMessage(TVM_DELETEITEM, 0, cast(LPARAM)TVI_ROOT);

		if(this._nodes)
		{
			this._nodes.clear();
		}
	}

	public final TreeNode addNode(string txt, int imgIndex = -1, int selImgIndex = -1)
	{
		if(!this._nodes)
		{
			this._nodes = new Collection!(TreeNode)();
		}

		TreeNode tn = new TreeNode(this, txt, imgIndex, selImgIndex == -1 ? imgIndex : selImgIndex);
		this._nodes.add(tn);

		if(this.created)
		{
			TreeView.createTreeNode(tn);
		}

		return tn;
	}

	public final void removeNode(TreeNode node)
	{
		if(this.created)
		{
			TreeView.removeTreeNode(node);
		}

		if(this._nodes)
		{
			this._nodes.remove(node);
		}
	}

	public final void removeNode(int idx)
	{
		TreeNode node = null;

		if(this._nodes)
		{
			node = this._nodes[idx];
		}

		if(node)
		{
			this.removeTreeNode(node);
		}
	}

	@property public final Collection!(TreeNode) nodes()
	{
		return this._nodes;
	}

	@property public final ImageList imageList()
	{
		return this._imgList;
	}

	@property public final void imageList(ImageList imgList)
	{
		this._imgList = imgList;

		if(this.created)
		{
			this.sendMessage(TVM_SETIMAGELIST, TVSIL_NORMAL, cast(LPARAM)this._imgList.handle);
		}
	}

	@property public final TreeNode selectedNode()
	{
		return this._selectedNode;
	}

	@property public final void selectedNode(TreeNode node)
	{
		this._selectedNode = node;

		if(this.created)
		{
			this.sendMessage(TVM_SELECTITEM, TVGN_FIRSTVISIBLE, cast(LPARAM)node.handle);
		}
	}

	public final void collapse()
	{
		if(this.created)
		{
			this.sendMessage(TVM_EXPAND, TVE_COLLAPSE, cast(LPARAM)TVI_ROOT);
		}
	}

	public final void expand()
	{
		if(this.created)
		{
			this.sendMessage(TVM_EXPAND, TVE_EXPAND, cast(LPARAM)TVI_ROOT);
		}
	}

	package static void createTreeNode(TreeNode node)
	{
		TVINSERTSTRUCTW tvis;

		tvis.hParent = node.parentNode ? node.parentNode.handle : cast(HTREEITEM)TVI_ROOT;
		tvis.hInsertAfter = cast(HTREEITEM)TVI_LAST;
		tvis.item.mask = TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_TEXT | TVIF_PARAM;
		tvis.item.iImage = node.imageIndex;
		tvis.item.iSelectedImage = node.selectedImageIndex;
		tvis.item.pszText  = toUTF16z(node.text);
		tvis.item.lParam = winCast!(LPARAM)(node);

		TreeView tvw = node.treeView;
		node.handle = cast(HTREEITEM)tvw.sendMessage(TVM_INSERTITEMW, 0, cast(LPARAM)&tvis);

		if(node.hasNodes)
		{
			node.doChildNodes();
		}

		node.expand();
		tvw.redraw();
	}

	package static void removeTreeNode(TreeNode node)
	{
		node.treeView.sendMessage(TVM_DELETEITEM, 0, cast(LPARAM)node.handle);
		//node.dispose();
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_TREEVIEW;
		pcw.ClassName = WC_DTREEVIEW;
		pcw.Style |= TVS_LINESATROOT | TVS_HASLINES | TVS_HASBUTTONS;
		pcw.ExtendedStyle = WS_EX_CLIENTEDGE;
		pcw.DefaultBackColor = SystemColors.colorWindow;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._imgList)
		{
			this.sendMessage(TVM_SETIMAGELIST, TVSIL_NORMAL, cast(LPARAM)this._imgList.handle);
		}

		if(this._nodes)
		{
			foreach(TreeNode tn; this._nodes)
			{
				TreeView.createTreeNode(tn);
			}
		}

		super.onHandleCreated(e);
	}

	protected override int onReflectedMessage(uint msg, WPARAM wParam, LPARAM lParam)
	{
		if(msg == WM_NOTIFY)
		{
			NMTREEVIEWW* pNotifyTreeView = cast(NMTREEVIEWW*)lParam;

			switch(pNotifyTreeView.hdr.code)
			{
				case TVN_SELCHANGINGW:
				{
					scope CancelEventArgs e = new CancelEventArgs();
					this.onSelectedNodeChanging(e);
					return e.cancel;
				}

				case TVN_SELCHANGEDW:
				{
					TreeNode oldNode = winCast!(TreeNode)(pNotifyTreeView.itemOld.lParam);
					TreeNode newNode = winCast!(TreeNode)(pNotifyTreeView.itemNew.lParam);

					this._selectedNode = newNode;
					scope TreeNodeChangedEventArgs e = new TreeNodeChangedEventArgs(oldNode, newNode);
					this.onSelectedNodeChanged(e);
				}
				break;

				case NM_RCLICK: //Trigger a WM_CONTEXMENU Message (Fixes the double click/context menu bug, probably it's a windows bug).
					this.wndProc(WM_CONTEXTMENU, 0, 0);
					break;

				default:
					break;
			}
		}

		return super.onReflectedMessage(msg, wParam, lParam);
	}

	/*
	protected override void onMouseKeyUp(MouseEventArgs e)
	{
		if(e.keys is MouseKeys.RIGHT)
		{
			this.sendMessage(WM_CONTEXTMENU, 0, 0);
		}

		super.onMouseKeyUp(e);
	}
	*/

	protected void onSelectedNodeChanging(CancelEventArgs e)
	{
		this.selectedNodeChanging(this, e);
	}

	protected void onSelectedNodeChanged(TreeNodeChangedEventArgs e)
	{
		this.selectedNodeChanged(this, e);
	}
}

/** DGui project file.

Copyright: Trogu Antonio Davide 2011-2013

License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Trogu Antonio Davide
*/
module dgui.layout.panel;

public import dgui.layout.layoutcontrol;

class Panel: LayoutControl
{
	protected override void createControlParams(ref CreateControlParams ccp)
	{
		ccp.ClassName = WC_DPANEL;
		ccp.DefaultCursor = SystemCursors.arrow;

		super.createControlParams(ccp);
	}
}

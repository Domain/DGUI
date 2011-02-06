module dgui.panel;

public import dgui.control;

private const string WC_DPANEL = "DPanel";

class Panel: ContainerControl
{
	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.ClassName = WC_DPANEL;

		super.preCreateWindow(pcw);
	}
}

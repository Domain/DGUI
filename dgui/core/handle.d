module dgui.core.handle;

abstract class Handle(T)
{
	protected T _handle;

	public final bool created()
	{
		return cast(bool)this._handle;
	}

	public /*final*/ T handle()
	{
		return this._handle;
	}
}

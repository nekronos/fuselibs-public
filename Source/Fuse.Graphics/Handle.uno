namespace Fuse.Graphics
{
	public struct Handle
	{
		readonly int _handle;

		Handle(int handle)
		{
			_handle = handle;
		}

		static int _counter = 0;
		public static Handle NewHandle()
		{
			return new Handle(_counter++);
		}

		public sealed override bool Equals(object other)
		{
			return other is Handle && ((Handle)other)._handle.Equals(_handle);
		}

		public sealed override int GetHashCode()
		{
			return _handle.GetHashCode();
		}

		public static bool operator ==(Handle x, Handle y)
		{
			return x._handle == y._handle;
		}

		public static bool operator !=(Handle x, Handle y)
		{
			return x._handle != y._handle;
		}
	}
}
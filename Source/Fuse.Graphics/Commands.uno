using Uno;

namespace Fuse.Graphics
{
	public class Context
	{
		internal readonly Handle Handle;
		internal readonly Action<Command> SendCommand;

		internal Context(Handle handle, Action<Command> sendCommand)
		{
			Handle = handle;
			SendCommand = sendCommand;
		}
	}

	public abstract class DrawableDelegate : IDisposable
	{
		Context _context;

		protected DrawableDelegate(Context context)
		{
			_context = context;
		}

		public Handle Handle
		{
			get { return _context.Handle; }
		}

		public void SendCommand(Command command)
		{
			_context.SendCommand(command);
		}

		public virtual void Dispose()
		{
			_context = null;
		}
	}

	public class DrawableDelegate<T> : DrawableDelegate where T : Drawable, new()
	{
		public DrawableDelegate(Context context) : base(context)
		{
			SendCommand(new DrawableRooted(Handle, New()));
		}

		protected Drawable New() { return new T(); }

		public override void Dispose()
		{
			SendCommand(new DrawableUnrooted(Handle));
			base.Dispose();
		}
	}

	public abstract class Command
	{
		internal abstract void Perform(DrawableControl drawableControl);
	}

	class DrawableRooted : Command
	{
		Handle _handle;
		Drawable _drawable;

		public DrawableRooted(Handle handle, Drawable drawable)
		{
			_handle = handle;
			_drawable = drawable;
		}

		internal override void Perform(DrawableControl drawableControl)
		{
			drawableControl.Root(_handle, _drawable);
		}
	}

	class DrawableUnrooted : Command
	{
		Handle _handle;

		public DrawableUnrooted(Handle handle)
		{
			_handle = handle;
		}

		internal override void Perform(DrawableControl drawableControl)
		{
			drawableControl.Unroot(_handle);
		}
	}

	public abstract class UpdateDrawable : Command
	{
		Handle _handle;

		protected UpdateDrawable(Handle handle)
		{
			_handle = handle;
		}

		internal sealed override void Perform(DrawableControl drawableControl)
		{
			Drawable drawable;
			if (drawableControl.TryGetDrawable(_handle, out drawable))
				Perform(drawable);
		}

		protected abstract void Perform(Drawable drawable);
	}

	public class UpdateTransform : UpdateDrawable
	{
		float4x4 _transform;

		public UpdateTransform(Handle handle, float4x4 transform) : base(handle)
		{
			_transform = transform;
		}

		protected override void Perform(Drawable drawable)
		{
			drawable.WorldTransform = _transform;
		}
	}

	public class UpdateSize : UpdateDrawable
	{
		float2 _size;

		public UpdateSize(Handle handle, float2 size) : base(handle)
		{
			_size = size;
		}

		protected override void Perform(Drawable drawable)
		{
			drawable.Size = _size;
		}
	}

}
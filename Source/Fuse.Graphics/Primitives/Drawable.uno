using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Threading;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Graphics
{
	public abstract class Drawable : IDisposable
	{
		public float2 Size;
		public float4x4 WorldTransform;
		public abstract void Draw(IRenderViewport viewport, DrawContext dc);
		public virtual void Dispose() {}
	}

	public abstract class Shape : Drawable
	{
		public Brush[] Fills;
		public Stroke[] Strokes;

		bool _ready = false;
		public override void Draw(IRenderViewport viewport, DrawContext dc)
		{
			if (!_ready)
			{
				if (Fills != null)
				{
					foreach (var fill in Fills)
					{
						fill.Pin();
						fill.Prepare(dc, Size);
					}
				}
				if (Strokes != null)
				{
					foreach (var stroke in Strokes)
					{
						stroke.Brush.Pin();
						stroke.Brush.Prepare(dc, Size);
					}
				}
				_ready = true;
			}
		}

		public override void Dispose()
		{
			if (_ready)
			{
				if (Fills != null)
					foreach (var fill in Fills)
						fill.Unpin();

				if (Strokes != null)
					foreach (var stroke in Strokes)
						stroke.Brush.Unpin();
				_ready = false;
			}
		}
	}
}
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
}
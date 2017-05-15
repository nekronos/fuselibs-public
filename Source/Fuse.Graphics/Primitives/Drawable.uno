using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Threading;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Graphics
{

	abstract class Drawable : IDisposable
	{
		public float2 Size;
		public float4x4 WorldTransform;
		public abstract void Draw(ImmutableViewport viewport, DrawContext dc);
		public virtual void Dispose() {}
	}

	abstract class Shape : Drawable
	{
		public Brush[] Fills;
		public Stroke[] Strokes;

		bool _ready = false;
		public override void Draw(ImmutableViewport viewport, DrawContext dc)
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

	class Rectangle : Shape
	{
		public float Smoothness = 1.0f;
		public float4 CornerRadius = float4(0.0f);

		public sealed override void Draw(ImmutableViewport viewport, DrawContext dc)
		{
			base.Draw(viewport, dc);
			if (Fills != null)
				foreach (var fill in Fills)
					Fuse.Graphics.Primitives.Rectangle.Singleton.Fill(viewport, dc, this, Size, CornerRadius, fill, float2(0.0f), Smoothness);

			if (Strokes != null)
				foreach (var stroke in Strokes)
					Fuse.Graphics.Primitives.Rectangle.Singleton.Stroke(viewport, dc, this, Size, CornerRadius, stroke, float2(0.0f), Smoothness);
		}

		public static Drawable MakeTestRect()
		{
			var rect = new Rectangle();
			rect.Size = float2(120.0f);
			rect.WorldTransform = Matrix.Translation(float3(100.0f, 100.0f, 0.0f));
			rect.Smoothness = 1.0f;
			rect.CornerRadius = float4(12.0f);
			rect.Fills = new Brush[] { new SolidColor(float4(1.0f, 0.0f, 0.0f, 1.0f)) };
			rect.Strokes = new Stroke[] { new Stroke(new SolidColor(float4(0.0f, 1.0f, 0.0f, 1.0f)), 4.0f) };
			return rect;
		}
	}
}
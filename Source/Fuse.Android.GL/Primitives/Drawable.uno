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

namespace Fuse.Android.GL
{
	abstract class Drawable : IDisposable
	{
		public float2 Size;
		public float4x4 WorldTransform;
		public abstract void Draw(ImmutableViewport viewport, DrawContext dc);
		public virtual void Dispose() {}
	}

	class Rectangle : Drawable
	{
		public float Smoothness;
		public float4 CornerRadius;
		public Brush[] Fills;
		public Stroke[] Strokes;

		public Rectangle(
			float2 size,
			float4x4 worldTransform,
			float smoothness,
			float4 cornerRadius,
			Brush[] fills,
			Stroke[] strokes)
		{
			Size = size;
			WorldTransform = worldTransform;
			Smoothness = smoothness;
			CornerRadius = cornerRadius;
			Fills = fills;
			Strokes = strokes;
		}

		bool _ready = false;
		public sealed override void Draw(ImmutableViewport viewport, DrawContext dc)
		{
			if (!_ready)
			{
				foreach (var fill in Fills)
				{
					fill.Pin();
					fill.Prepare(dc, Size);
				}
				foreach (var stroke in Strokes)
				{
					stroke.Brush.Pin();
					stroke.Brush.Prepare(dc, Size);
				}
				_ready = true;
			}

			foreach (var fill in Fills)
				Fuse.Android.GL.Primitives.Rectangle.Singleton.Fill(viewport, dc, this, Size, CornerRadius, fill, float2(0.0f), Smoothness);

			foreach (var stroke in Strokes)
				Fuse.Android.GL.Primitives.Rectangle.Singleton.Stroke(viewport, dc, this, Size, CornerRadius, stroke, float2(0.0f), Smoothness);

		}

		public override void Dispose()
		{
			base.Dispose();
			if (_ready)
			{
				foreach (var fill in Fills)
					fill.Unpin();

				foreach (var stroke in Strokes)
					stroke.Brush.Unpin();
				_ready = false;
			}
		}

		public static Drawable MakeTestRect()
		{
			return new Rectangle(
				float2(120.0f),
				Matrix.Translation(float3(100.0f, 100.0f, 0.0f)),
				1.0f,
				float4(12.0f),
				new Brush[] { new SolidColor(float4(1.0f, 0.0f, 0.0f, 1.0f)) },
				new Stroke[] { new Stroke(new SolidColor(float4(0.0f, 1.0f, 0.0f, 1.0f)), 4.0f) });
		}
	}
}
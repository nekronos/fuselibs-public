using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Controls;

namespace Fuse.Graphics
{
	class ImmutableViewport : IRenderViewport
	{
		public float PixelsPerPoint { get; private set; }
		public float2 Size { get; private set; }
		public float2 PixelSize { get; private set; }
		public float4x4 ViewTransform { get; private set; }
		public float4x4 ProjectionTransform { get; private set; }
		public float4x4 ViewProjectionTransform { get; private set; }
		public float3 ViewOrigin { get; private set; }
		public float2 ViewRange { get; private set; }

		public ImmutableViewport(
			float pixelsPerPoint,
			float2 size,
			float2 pixelSize,
			float4x4 viewTransform,
			float4x4 projectionTransform,
			float4x4 viewProjectionTransform,
			float3 viewOrigin,
			float2 viewRange)
		{
			PixelsPerPoint = pixelsPerPoint;
			Size = size;
			PixelSize = pixelSize;
			ViewTransform = viewTransform;
			ProjectionTransform = projectionTransform;
			ViewProjectionTransform = viewProjectionTransform;
			ViewOrigin = viewOrigin;
			ViewRange = viewRange;
		}
	}
}
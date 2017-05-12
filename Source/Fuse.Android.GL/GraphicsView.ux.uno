using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Controls;

namespace Fuse.Android.GL
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

	extern(!Android)
	public abstract class GraphicsViewBase : LayoutControl, ISurfaceTextureListener { }

	extern(Android)
	public abstract class GraphicsViewBase : LayoutControl, ISurfaceTextureListener, ITreeRenderer, IViewport
	{
		public sealed override VisualContext VisualContext
		{
			get { return VisualContext.Graphics; }
		}

		public sealed override ITreeRenderer TreeRenderer
		{
			get { return this; }
		}

		ITreeRenderer GetTreeRenderer(Element e)
		{
			return  e == this ? base.TreeRenderer : _treeRenderer;
		}

		FrustumViewport _frustumViewport = new FrustumViewport();
		OrthographicFrustum _frustum = new OrthographicFrustum();

		GLRenderer _treeRenderer;

		protected GraphicsViewBase()
		{
			_frustumViewport.Update(this, _frustum);
			_treeRenderer = new GLRenderer();
		}

		bool _frameScheduled = false;
		protected override void OnInvalidateVisual()
		{
			base.OnInvalidateVisual();
			ScheduleFrame();
		}

		void ScheduleFrame()
		{
			if (!_frameScheduled)
			{
				UpdateManager.AddOnceAction(PrepareFrame, UpdateStage.Draw);
				_frameScheduled = true;
			}
		}

		void PrepareFrame()
		{
			if (!IsRootingCompleted)
				return;

			_frameScheduled = false;

			_frustum.LocalFromWorld = WorldTransformInverse;
			_frustumViewport.Update(this, _frustum);

			_treeRenderer.EnqueueFrame(NewRenderViewport());

		}

		void ISurfaceTextureListener.OnAvailable(object surfaceTexture, int width, int height)
		{
			InvalidateVisual();
			((ISurfaceTextureListener)_treeRenderer).OnAvailable(surfaceTexture, width, height);
		}

		bool ISurfaceTextureListener.OnDestroyed(object surfaceTexture)
		{
			return ((ISurfaceTextureListener)_treeRenderer).OnDestroyed(surfaceTexture);
		}

		void ISurfaceTextureListener.OnSizeChanged(object surfaceTexture, int width, int height)
		{
			((ISurfaceTextureListener)_treeRenderer).OnSizeChanged(surfaceTexture, width, height);
		}

		void ISurfaceTextureListener.OnUpdated(object surfaceTexture)
		{
			((ISurfaceTextureListener)_treeRenderer).OnUpdated(surfaceTexture);
		}

		// TODO: refactor this bloat away
		void ITreeRenderer.RootingStarted(Element e) { GetTreeRenderer(e).RootingStarted(e); }
		void ITreeRenderer.Rooted(Element e) { GetTreeRenderer(e).Rooted(e); }
		void ITreeRenderer.Unrooted(Element e) { GetTreeRenderer(e).Unrooted(e); }
		void ITreeRenderer.BackgroundChanged(Element e, Brush background) { GetTreeRenderer(e).BackgroundChanged(e, background); }
		void ITreeRenderer.TransformChanged(Element e) { GetTreeRenderer(e).TransformChanged(e); }
		void ITreeRenderer.Placed(Element e) { GetTreeRenderer(e).Placed(e); }
		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible) { GetTreeRenderer(e).IsVisibleChanged(e, isVisible); }
		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled) { GetTreeRenderer(e).IsEnabledChanged(e, isEnabled); }
		void ITreeRenderer.OpacityChanged(Element e, float opacity) { GetTreeRenderer(e).OpacityChanged(e, opacity); }
		void ITreeRenderer.ClipToBoundsChanged(Element e, bool clipToBounds) { GetTreeRenderer(e).ClipToBoundsChanged(e, clipToBounds); }
		void ITreeRenderer.HitTestModeChanged(Element e, bool enabled) { GetTreeRenderer(e).HitTestModeChanged(e, enabled); }
		void ITreeRenderer.ZOrderChanged(Element e, List<Visual> zorder) { /*GetTreeRenderer(e).ZOrderChanged(e, zorder);*/ }
		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size) { return GetTreeRenderer(e).Measure(e, lp, out size); }

		public float PixelsPerPoint
		{
			get
			{
				return Parent != null
					? Parent.Viewport.PixelsPerPoint
					: AppBase.Current.PixelsPerPoint;
			}
		}

		public float2 Size
		{
			get { return ActualSize; }
		}

		public float2 PixelSize
		{
			get { return ActualSize * PixelsPerPoint; }
		}

		public float4x4 ViewTransform
		{
			get { return _frustumViewport.ViewTransform; }
		}

		public Ray PointToWorldRay(float2 pixelPos)
		{
			return ViewportHelpers.PointToWorldRay(this, _frustumViewport.ViewProjectionTransformInverse, pixelPos);
		}
		public Ray WorldToLocalRay(IViewport world, Ray worldRay, Visual where)
		{
			return ViewportHelpers.WorldToLocalRay(this, world, worldRay, where);
		}

		ImmutableViewport NewRenderViewport()
		{
			return new ImmutableViewport(
				PixelsPerPoint,
				Size,
				PixelSize,
				ViewTransform,
				_frustumViewport.ProjectionTransform,
				_frustumViewport.ViewProjectionTransform,
				_frustum.GetWorldPosition(this),
				_frustum.GetDepthRange(this));
		}
	}
}
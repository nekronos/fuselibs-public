using Uno;
using Uno.UX;
using Uno.Collections;
using Uno.Threading;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Graphics.Android;
using Fuse.Graphics.Commands;

namespace Fuse.Graphics
{
	class GLRenderer : ITreeRenderer, ISurfaceTextureListener
	{

		ConcurrentQueue<Frame> _frameQueue = new ConcurrentQueue<Frame>();

		public GLRenderer()
		{

		}

		public void EnqueueFrame(ImmutableViewport viewport)
		{

		}

		RenderControl _renderControl;

		extern(Android) void ISurfaceTextureListener.OnAvailable(object surfaceTexture, int width, int height)
		{
			_renderControl = new RenderControl(surfaceTexture, _frameQueue);
		}

		extern(Android) bool ISurfaceTextureListener.OnDestroyed(object surfaceTexture)
		{
			return false;
		}

		extern(Android) void ISurfaceTextureListener.OnSizeChanged(object surfaceTexture, int width, int height)
		{

		}

		extern(Android) void ISurfaceTextureListener.OnUpdated(object surfaceTexture)
		{

		}

		int _handleCounter = 0;
		Dictionary<Element, Handle> _elements = new Dictionary<Element, Handle>();

		void ITreeRenderer.RootingStarted(Element e)
		{
			var handle = Handle.NewHandle();
			_elements.Add(e, handle);
		}

		void ITreeRenderer.Rooted(Element e)
		{

		}

		void ITreeRenderer.Unrooted(Element e)
		{

		}

		void ITreeRenderer.BackgroundChanged(Element e, Brush background)
		{

		}

		void ITreeRenderer.TransformChanged(Element e)
		{

		}

		void ITreeRenderer.Placed(Element e)
		{

		}

		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible)
		{

		}

		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled)
		{

		}

		void ITreeRenderer.OpacityChanged(Element e, float opacity)
		{

		}

		void ITreeRenderer.ClipToBoundsChanged(Element e, bool clipToBounds)
		{

		}

		void ITreeRenderer.HitTestModeChanged(Element e, bool enabled)
		{

		}

		void ITreeRenderer.ZOrderChanged(Element e, List<Visual> zorder)
		{

		}

		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size)
		{
			size = float2(0.0f);
			return false;
		}


	}
}
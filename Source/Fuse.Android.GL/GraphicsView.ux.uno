using Fuse.Elements;
using Fuse.Controls;

namespace Fuse.Android.GL
{
	public abstract class GraphicsViewBase : LayoutControl, ISurfaceTextureListener
	{
		public sealed override VisualContext VisualContext
		{
			get { return VisualContext.Graphics; }
		}

		public sealed override ITreeRenderer GetTreeRenderer(Element e)
		{
			if (e == this)
				return base.GetTreeRenderer(e);
			else
				return _treeRenderer;
		}

		GLRenderer _treeRenderer;

		public GraphicsViewBase()
		{
			_treeRenderer = new GLRenderer();
		}

		void ISurfaceTextureListener.OnAvailable(object surfaceTexture, int width, int height)
		{
			debug_log("ISurfaceTextureListener.OnAvailable( " + width + ", " + height + " )");
		}

		bool ISurfaceTextureListener.OnDestroyed(object surfaceTexture)
		{
			debug_log("ISurfaceTextureListener.OnDestroyed( )");
			return false;
		}

		void ISurfaceTextureListener.OnSizeChanged(object surfaceTexture, int width, int height)
		{
			debug_log("ISurfaceTextureListener.OnSizeChanged( " + width + ", " + height + " )");
		}

		void ISurfaceTextureListener.OnUpdated(object surfaceTexture)
		{
			debug_log("ISurfaceTextureListener.OnUpdated( )");
		}
	}
}
using Uno;
using Uno.UX;
using Uno.Collections;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Android.GL
{
	class GLRenderer : ITreeRenderer
	{
		public GLRenderer()
		{

		}

		void ITreeRenderer.RootingStarted(Element e)
		{

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
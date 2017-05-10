using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Collections;
using Fuse;
using Fuse.Drawing;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Controls.Native;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Controls.Android
{
	extern(Android) class TreeRenderer2 : ITreeRenderer
	{

		public delegate void InsertChildHandler(ViewHandle child);
		public delegate void RemoveChildHandler(ViewHandle child);

		InsertChildHandler _insertChild;
		RemoveChildHandler _removeChild;

		Element _rootElement;

		public TreeRenderer2(Element rootElement, InsertChildHandler insertChild, RemoveChildHandler removeChild)
		{
			_rootElement = rootElement;
			_insertChild = insertChild;
			_removeChild = removeChild;
			UpdateManager.AddAction(OnUpdate, UpdateStage.Draw);
		}

		bool _treeValid = false;

		void OnUpdate()
		{
			if (!_treeValid)
			{
				if (_rootElement.TreeHandle != TreeHandle.Null)
				{
					var rootViewNode = _viewNodes[_rootElement.TreeHandle];
					debug_log("input:");
					debug_log(ViewNodeExtensions.Stringify(rootViewNode));
					debug_log("Output:");
					var flattenedViewNodes = rootViewNode.Flatten();
					foreach (var node in flattenedViewNodes)
					{
						debug_log(node.Stringify());
					}
				}
				_treeValid = true;
			}
		}

		void Invalidate()
		{
			_treeValid = false;
		}

		Dictionary<TreeHandle,ViewNode> _viewNodes = new Dictionary<TreeHandle,ViewNode>();
		Dictionary<TreeHandle,ViewHandle> _viewHandles = new Dictionary<TreeHandle,ViewHandle>();

		ViewNode GetParentViewNode(Element e)
		{
			var parent = e.Parent as Element;
			return parent != null && parent.TreeHandle != TreeHandle.Null
				? _viewNodes[parent.TreeHandle]
				: null;
		}

		ViewNode GetViewNode(Element e)
		{
			var handle = e.TreeHandle;
			if (handle == TreeHandle.Null)
				throw new Exception(e.ToString() + ".TreeHandle == null");

			return _viewNodes[handle];
		}

		void SortViewNodes(Element parent)
		{
			var len = parent.ZOrderChildCount;
			var root = GetViewNode(parent);
			root.Children.Clear();
			for (var i = 0; i < len; i++)
			{
				var child = parent.GetZOrderChild(i) as Element;
				if (child != null)
					root.Children.AddLast(GetViewNode(child));
			}
		}

		void ITreeRenderer.RootingStarted(Element e)
		{
			var handle = e.TreeHandle = TreeHandle.New();
			var viewNode = new ViewNode(handle);
			_viewNodes.Add(handle, viewNode);

			var viewHandle = InstantiateView(e);
			_viewHandles.Add(handle, viewHandle);

			var parent = GetParentViewNode(e);
			if (parent != null)
				parent.Children.AddLast(viewNode);

			_treeValid = false;
		}

		void ITreeRenderer.Rooted(Element e)
		{

		}

		void ITreeRenderer.Unrooted(Element e)
		{

		}

		void ITreeRenderer.BackgroundChanged(Element e, Brush background)
		{
			_viewHandles[e.TreeHandle].SetBackgroundColor(background.GetColor());
		}

		void ITreeRenderer.TransformChanged(Element e)
		{

		}

		void ITreeRenderer.Placed(Element e)
		{

		}

		void ITreeRenderer.IsVisibleChanged(Element e, bool isVisible)
		{
			GetViewNode(e).IsVisible = isVisible;
			Invalidate();
		}

		void ITreeRenderer.IsEnabledChanged(Element e, bool isEnabled)
		{
			GetViewNode(e).IsEnabled = isEnabled;
			Invalidate();
		}

		void ITreeRenderer.OpacityChanged(Element e, float opacity)
		{
			GetViewNode(e).Opacity = opacity;
			Invalidate();
		}

		void ITreeRenderer.ClipToBoundsChanged(Element e, bool clipToBounds)
		{
			GetViewNode(e).ClipToBounds = clipToBounds;
			Invalidate();
		}

		void ITreeRenderer.HitTestModeChanged(Element e, bool enabled)
		{
			GetViewNode(e).HitTestEnabled = enabled;
			Invalidate();
		}

		void ITreeRenderer.ZOrderChanged(Element e, List<Visual> zorder)
		{
			SortViewNodes(e);
			Invalidate();
		}

		bool ITreeRenderer.Measure(Element e, LayoutParams lp, out float2 size)
		{
			size = float2(0.0f);
			return false;
		}

		ViewHandle InstantiateView(Element e)
		{
			var appearance = (InstantiateTemplate(e) ?? InstantiateViewOld(e)) as ViewHandle;
			if (appearance != null)
			{
				if (e is Control)
				{
					((Control)e).ViewHandle = appearance;
					if (appearance is IView)
						((Control)e).NativeView = (IView)appearance;
				}
				return appearance;
			}
			else
			{
				return ViewFactory.InstantiateViewGroup();
			}
		}

		object InstantiateTemplate(Element e)
		{
			var t = e.FindTemplate("AndroidAppearance");
			return t != null ? t.New() : null;
		}

		// For backwardscompatibility with old pattern
		object InstantiateViewOld(Element e)
		{
			if (e is Control)
			{
				var c = (Control)e;
				return c.InstantiateNativeView();
			}
			return null;
		}

	}
}
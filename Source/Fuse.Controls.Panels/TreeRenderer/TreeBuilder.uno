using Uno;
using Uno.UX;
using Uno.Text;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Controls.Native;

namespace Fuse.Controls.Android
{
	extern(Android) class TreeBuilder
	{
		public static void Build(
			TreeRenderer2.InsertChildHandler insertChild,
			LinkedList<ViewNode> viewNodes,
			Dictionary<TreeHandle,ViewHandle> viewHandles)
		{
			foreach (var node in viewNodes)
			{
				var viewHandle = viewHandles[node.TreeHandle];
				UpdateState(node, viewHandle);
				insertChild(viewHandle);
				Build(node, viewHandles);
			}
		}

		static void Build(
			ViewNode parent,
			Dictionary<TreeHandle,ViewHandle> viewHandles)
		{
			var parentViewHandle = viewHandles[parent.TreeHandle];
			foreach (var child in parent.Children)
			{
				var viewHandle = viewHandles[child.TreeHandle];
				UpdateState(child, viewHandle);
				parentViewHandle.InsertChild(viewHandle);
				Build(child, viewHandles);
			}
		}

		public static void TearDown(
			TreeRenderer2.RemoveChildHandler removeChild,
			LinkedList<ViewNode> viewNodes,
			Dictionary<TreeHandle,ViewHandle> viewHandles)
		{
			foreach (var node in viewNodes)
			{
				TearDown(node, viewHandles);
				removeChild(viewHandles[node.TreeHandle]);
			}
		}

		static void TearDown(
			ViewNode parent,
			Dictionary<TreeHandle,ViewHandle> viewHandles)
		{
			var parentViewHandle = viewHandles[parent.TreeHandle];
			foreach (var child in parent.Children)
			{
				TearDown(child, viewHandles);
				parentViewHandle.RemoveChild(viewHandles[child.TreeHandle]);
			}
		}

		static void UpdateState(ViewNode viewNode, ViewHandle viewHandle)
		{
			viewHandle.SetIsVisible(viewNode.IsVisible);
			viewHandle.SetEnabled(viewNode.IsEnabled);
			viewHandle.SetHitTestEnabled(viewNode.HitTestEnabled);
			viewHandle.SetClipToBounds(viewNode.ClipToBounds);
			viewHandle.SetOpacity(viewNode.Opacity);
		}
	}
}
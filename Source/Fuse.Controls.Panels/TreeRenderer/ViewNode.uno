using Uno;
using Uno.Text;
using Uno.Collections;
using Fuse.Elements;

namespace Fuse.Controls.Android
{
	class ViewNode
	{
		public enum State : int
		{
			IsVisible = 0,
			IsEnabled,
			HitTestEnabled,
			ClipToBounds,
		}

		public bool IsVisible
		{
			get { return GetState(State.IsVisible); }
			set { SetState(State.IsVisible, value); }
		}

		public bool IsEnabled
		{
			get { return GetState(State.IsEnabled); }
			set { SetState(State.IsEnabled, value); }
		}

		public bool HitTestEnabled
		{
			get { return GetState(State.HitTestEnabled); }
			set { SetState(State.HitTestEnabled, value); }
		}

		public bool ClipToBounds
		{
			get { return GetState(State.ClipToBounds); }
			set { SetState(State.ClipToBounds, value); }
		}

		public readonly LinkedList<ViewNode> Children = new LinkedList<ViewNode>();
		public readonly TreeHandle TreeHandle;
		public readonly bool[] _state = new bool[4];

		public float Opacity = 1.0f;

		public ViewNode(TreeHandle treeHandle)
		{
			TreeHandle = treeHandle;
			IsVisible = true;
			IsEnabled = true;
			HitTestEnabled = true;
			ClipToBounds = false;
		}

		public bool GetState(State state)
		{
			return _state[(int)state];
		}

		public void SetState(State state, bool value)
		{
			_state[(int)state] = value;
		}

		public override string ToString()
		{
			return TreeHandle.ToString() + " Node";
		}
	}

	static class ViewNodeExtensions
	{
		public static LinkedList<ViewNode> Flatten(this ViewNode input)
		{
			var result = new LinkedList<ViewNode>();
			Flatten(result, input);
			return result;
		}

		static void Flatten(LinkedList<ViewNode> result, ViewNode input)
		{
			var outputNode = new ViewNode(input.TreeHandle);
			var linkNode = result.AddLast(outputNode);

			var cannotFlatten = input.ClipToBounds || input.Opacity < 1.0f;
			if (cannotFlatten)
			{
				outputNode.ClipToBounds = input.ClipToBounds;
				outputNode.Opacity = input.Opacity;
				foreach (var child in input.Children)
					Flatten(outputNode.Children, child);
			}
			else
			{
				foreach (var child in input.Children)
					Flatten(result, child);
			}

			if (!input.IsVisible)
				SetStateRecursive(linkNode, ViewNode.State.IsVisible, false);

			if (!input.IsEnabled)
				SetStateRecursive(linkNode, ViewNode.State.IsEnabled, false);

			if (!input.HitTestEnabled)
				SetStateRecursive(linkNode, ViewNode.State.HitTestEnabled, false);
		}

		static void SetStateRecursive(LinkedListNode<ViewNode> linkNode, ViewNode.State state, bool value)
		{
			while(linkNode != null)
			{
				SetStateRecursive(linkNode.Value, state, value);
				linkNode = linkNode.Next;
			}
		}

		static void SetStateRecursive(ViewNode parent, ViewNode.State state, bool value)
		{
			parent.SetState(state, value);
			foreach(var child in parent.Children)
				SetStateRecursive(child, state, value);
		}

		public static string Stringify(this ViewNode viewNode)
		{
			var builder = new StringBuilder();
			Stringify(viewNode, builder);
			return builder.ToString();
		}

		static void Stringify(ViewNode viewNode, StringBuilder builder, int indent = 0)
		{
			Indent(builder, indent);
			builder.Append(viewNode.ToString());
			foreach (var child in viewNode.Children)
			{
				builder.Append("\n");
				Stringify(child, builder, indent + 1);
			}
		}

		static void Indent(StringBuilder builder, int indent)
		{
			for (var i = 0; i < indent; i++)
				builder.Append("  ");
		}
	}
}
using Uno;
using Uno.Collections;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;

namespace Fuse
{

	using Fuse.Controls;
	using Fuse.Controls.Native;
	using Fuse.Android;
	using Fuse.Input;

	extern (Android && Oculus && !Library) public abstract class VrApp: AppBase
	{
		RootGraphicsView _graphicsView = new RootGraphicsView();

		Visual RootVisual
		{
			get { return _graphicsView; }
		}

		static VrApp Instance
		{
			get { return Uno.Application.Current as VrApp; }
		}

		protected VrApp()
		{
			Fuse.Platform.SystemUI.OnCreate();

			Fuse.Android.StatusBarConfig.SetStatusBarColor(float4(0));

			Fuse.Controls.TextControl.TextRendererFactory = Fuse.Android.TextRenderer.Create;

			MobileBootstrapping.Init();

			RootViewport = new NativeRootViewport(AppRoot.ViewHandle);
			RootViewport.Children.Add(_graphicsView);

			Uno.Platform.Displays.MainDisplay.Tick += OnTick;

			Uno.VrEntryPoint.SetClickedHandler(OnClick);
			Uno.VrEntryPoint.SetPointerDownHandler(OnPointerDown);
			Uno.VrEntryPoint.SetPointerMovedHandler(OnPointerMove);
			Uno.VrEntryPoint.SetPointerUpHandler(OnPointerUp);
		}

		public sealed override IList<Node> Children
		{
			get { return RootVisual.Children; }
		}

		public sealed override Visual ChildrenVisual
		{
			get { return RootVisual; }
		}

		class DeferReleased
		{
			float2 _point;

			public DeferReleased(float2 point)
			{
				_point = point;
				UpdateManager.PerformNextFrame(OnRelease);
			}

			void OnRelease()
			{
				var releasedEvent = new PointerEventData()
				{
					PointIndex = 0,
					WindowPoint = _point,
					Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
					PointerType = Uno.Platform.PointerType.Touch,
					IsPrimary = true,
				};
				Fuse.Input.Pointer.RaiseReleased(VrApp.Instance.RootVisual, releasedEvent);
			}
		}

		abstract class InputEvent
		{
			protected readonly double _timeStamp;
			protected readonly float2 _coord;

			public InputEvent(double timeStamp, float2 coord)
			{
				_timeStamp = timeStamp;
				_coord = coord;
			}

			public void Dispatch()
			{
				RaiseEvent(new PointerEventData()
				{
					PointIndex = 0,
					WindowPoint = _coord / VrApp.Instance.RootVisual.Viewport.PixelsPerPoint,
					Timestamp = _timeStamp,
					PointerType = Uno.Platform.PointerType.Touch,
					IsPrimary = true,
				});
			}

			protected abstract void RaiseEvent(PointerEventData pointerEventData);
		}

		class DownEvent : InputEvent
		{
			public DownEvent(double timeStamp, float2 coord) : base(timeStamp, coord) {}
			protected override void RaiseEvent(PointerEventData pointerEventData) { Fuse.Input.Pointer.RaisePressed(VrApp.Instance.RootVisual, pointerEventData); }
		}

		class MovedEvent : InputEvent
		{
			public MovedEvent(double timeStamp, float2 coord) : base(timeStamp, coord) {}
			protected override void RaiseEvent(PointerEventData pointerEventData) { Fuse.Input.Pointer.RaiseMoved(VrApp.Instance.RootVisual, pointerEventData); }
		}

		class UpEvent : InputEvent
		{
			public UpEvent(double timeStamp, float2 coord) : base(timeStamp, coord) {}
			protected override void RaiseEvent(PointerEventData pointerEventData) { Fuse.Input.Pointer.RaiseReleased(VrApp.Instance.RootVisual, pointerEventData); }
		}

		void OnClick(float x, float y)
		{
			/*var pressedEvent = new PointerEventData()
			{
				PointIndex = 0,
				WindowPoint = float2(x, y) / RootVisual.Viewport.PixelsPerPoint,
				Timestamp = Uno.Diagnostics.Clock.GetSeconds(),
				PointerType = Uno.Platform.PointerType.Touch,
				IsPrimary = true,
			};
			Fuse.Input.Pointer.RaisePressed(RootVisual, pressedEvent);
			new DeferReleased(float2(x, y) / RootVisual.Viewport.PixelsPerPoint);*/
		}

		void OnPointerDown(float x, float y)
		{
			UpdateManager.PostAction(new DownEvent(Uno.Diagnostics.Clock.GetSeconds(), float2(x, y)).Dispatch);
		}

		void OnPointerUp(float x, float y)
		{
			UpdateManager.PostAction(new UpEvent(Uno.Diagnostics.Clock.GetSeconds(), float2(x, y)).Dispatch);
		}

		void OnPointerMove(float x, float y)
		{
			UpdateManager.PostAction(new MovedEvent(Uno.Diagnostics.Clock.GetSeconds(), float2(x, y)).Dispatch);
		}

		void OnTick(object sender, Uno.Platform.TimerEventArgs args)
		{
			RootViewport.InvalidateLayout();
			try
			{
				PropagateBackground();
			}
			catch (Exception e)
			{
				Fuse.AppBase.OnUnhandledExceptionInternal(e);
			}

			Time.Set(args.CurrentTime);

			try
			{
				OnUpdate();
			}
			catch (Exception e)
			{
				Fuse.AppBase.OnUnhandledExceptionInternal(e);
			}
		}

		void PropagateBackground()
		{
			_graphicsView.Color = Background;
		}
	}

	extern (Android && Oculus && !Library) public abstract class App: VrApp {}
}

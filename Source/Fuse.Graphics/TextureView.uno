using Uno;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Controls.Native;

namespace Fuse.Graphics.Android
{
	extern(!Android)
	interface ISurfaceTextureListener {}

	extern(Android)
	interface ISurfaceTextureListener
	{
		void OnAvailable(object surfaceTexture, int width, int height);
		bool OnDestroyed(object surfaceTexture);
		void OnSizeChanged(object surfaceTexture, int width, int height);
		void OnUpdated(object surfaceTexture);
	}

	extern(!Android) class TextureView
	{
		[UXConstructor]
		public TextureView([UXParameter("SurfaceTextureListener")]ISurfaceTextureListener surfaceListener) { }
	}
	extern(Android) class TextureView : ViewHandle
	{
		ISurfaceTextureListener _surfaceListener;

		[UXConstructor]
		public TextureView([UXParameter("SurfaceTextureListener")]ISurfaceTextureListener surfaceListener) : base(Create())
		{
			_surfaceListener = surfaceListener;
			InstallSurfaceListener(
				NativeHandle,
				_surfaceListener.OnAvailable,
				_surfaceListener.OnDestroyed,
				_surfaceListener.OnSizeChanged,
				_surfaceListener.OnUpdated);
		}

		public override void Dispose()
		{
			_surfaceListener = null;
			base.Dispose();
		}

		[Foreign(Language.Java)]
		void InstallSurfaceListener(
			Java.Object handle,
			Action<Java.Object,int,int> onAvailable,
			Func<Java.Object,bool> OnDestroyed,
			Action<Java.Object,int,int> onSizeChanged,
			Action<Java.Object> onUpdated)
		@{
			((android.view.TextureView)handle).setSurfaceTextureListener(new android.view.TextureView.SurfaceTextureListener() {
				public void onSurfaceTextureAvailable(android.graphics.SurfaceTexture surface, int width, int height) {
					onAvailable.run(surface, width, height);
				}
				public boolean onSurfaceTextureDestroyed(android.graphics.SurfaceTexture surface) {
					return OnDestroyed.run(surface);
				}
				public void onSurfaceTextureSizeChanged(android.graphics.SurfaceTexture surface, int width, int height) {
					onSizeChanged.run(surface, width, height);
				}
				public void onSurfaceTextureUpdated(android.graphics.SurfaceTexture surface) {
					onUpdated.run(surface);
				}
			});
		@}

		[Foreign(Language.Java)]
		static Java.Object Create()
		@{
			android.view.TextureView textureView = new android.view.TextureView(com.fuse.Activity.getRootActivity());
			textureView.setLayoutParams(new android.widget.FrameLayout.LayoutParams(android.view.ViewGroup.LayoutParams.FILL_PARENT, android.view.ViewGroup.LayoutParams.FILL_PARENT));
			textureView.setBackgroundColor((int)0xffffcc00);
			return textureView;
		@}
	}
}
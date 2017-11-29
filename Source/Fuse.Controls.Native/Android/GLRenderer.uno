using Uno;
using Uno.Graphics;
using Uno.Compiler.ExportTargetInterop;
using OpenGL;
using Fuse;
using Fuse.Controls;

namespace Fuse.Controls.Native.Android
{
	extern(ANDROID) public class GLRenderer
	{
		VideoTexture _videoTexture;
		GLTextureHandle _textureHandle = GLTextureHandle.Zero;

		Java.Object _surfaceTexture;
		Java.Object _surface;

		int2 _textureSize = int2(-1);
		int _surfaceTextureVersion = 0;

		public GLRenderer()
		{

		}

		public void Draw(
			ViewHandle viewHandle,
			float4x4 localToClipTransform,
			float2 position,
			float2 size,
			float density)
		{
			var pixelSize = size * density;
			if (_textureSize != pixelSize)
			{
				_textureSize = pixelSize;
				ReleaseResources();
				_textureHandle = GL.CreateTexture();
				_videoTexture = new VideoTexture(_textureHandle);
				_surfaceTexture = NewSurfaceTexture(_surfaceTextureVersion++, (int)_textureHandle, OnFrameAvailable, pixelSize.X, pixelSize.Y);
				_surface = NewSurface(_surfaceTexture);
			}

			// SurfaceTextureUpdateTexImage

			Draw(_surface, viewHandle.NativeHandle);

			Blitter.Singleton.Blit(_videoTexture, position, size, localToClipTransform);
		}

		public void Blit()
		{

		}

		public void UpdateTexture()
		{
			SurfaceTextureUpdateTexImage(_surfaceTexture);
		}

		// Have to dispatch to UI thread, its undefined
		// what thread this callback will be run on
		void OnFrameAvailable(int surfaceTextureVersion)
		{
			if (_surfaceTextureVersion != surfaceTextureVersion)
				return;
		}

		void ReleaseResources()
		{
			if (_surface != null)
			{
				SurfaceRelease(_surface);
				_surface = null;
			}
			if (_surfaceTexture != null)
			{
				SurfaceTextureRelease(_surfaceTexture);
				_surfaceTexture = null;
			}
			if (_textureHandle != GLTextureHandle.Zero)
			{
				GL.DeleteTexture(_textureHandle);
				_textureHandle = GLTextureHandle.Zero;
			}
		}

		void Blit(VideoTexture vt, float2 pos, float2 size, float4x4 localToClipTransform)
		{
			draw
			{
				apply Fuse.Drawing.PreMultipliedAlphaCompositing;

				CullFace : PolygonFace.None;
				DepthTestEnabled: false;
				float2[] verts: readonly new float2[] {

					float2(0,0),
					float2(1,0),
					float2(1,1),
					float2(0,0),
					float2(1,1),
					float2(0,1)
				};

				float2 v: vertex_attrib(verts);
				float2 LocalVertex: pos + v * size;
				ClipPosition: Vector.Transform(LocalVertex, localToClipTransform);
				float2 TexCoord: v;

				PixelColor: sample(vt, TexCoord);
			};
		}

		[Foreign(Language.Java)]
		Java.Object NewSurfaceTexture(int version, int textureName, Action frameAvailableCallback, int w, int h)
		@{
			android.graphics.SurfaceTexture st = new android.graphics.SurfaceTexture(textureName);
			st.setDefaultBufferSize(w, h);
			st.setOnFrameAvailableListener(new android.graphics.SurfaceTexture.OnFrameAvailableListener() {
					final int _version = version;
					public void onFrameAvailable(android.graphics.SurfaceTexture surfaceTexture) {
						frameAvailableCallback.run(_version);
					}
				});
			return st;
		@}

		[Foreign(Language.Java)]
		void SurfaceTextureUpdateTexImage(Java.Object handle)
		@{
			((android.graphics.SurfaceTexture)handle).updateTexImage();
		@}

		[Foreign(Language.Java)]
		void SurfaceTextureRelease(Java.Object handle)
		@{
			((android.graphics.SurfaceTexture)handle).release();
		@}

		[Foreign(Language.Java)]
		Java.Object NewSurface(Java.Object surfaceTexture)
		@{
			return new android.view.Surface((android.graphics.SurfaceTexture)surfaceTexture);
		@}

		[Foreign(Language.Java)]
		void SurfaceRelease(Java.Object handle)
		@{
			((android.view.Surface)handle).release();
		@}

		[Foreign(Language.Java)]
		void Draw(Java.Object surfaceHandle, Java.Object viewHandle)
		@{
			android.view.Surface surface = (android.view.Surface)surfaceHandle;
			android.view.View view = (android.view.View)viewHandle;
			android.graphics.Canvas canvas = surface.lockHardwareCanvas();
			view.draw(canvas);
			surface.unlockCanvasAndPost(canvas);
		@}
	}
}

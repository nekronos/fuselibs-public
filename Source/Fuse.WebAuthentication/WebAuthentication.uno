using Uno;
using Uno.UX;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;
using Uno.Collections;
using Fuse.Scripting;

namespace Fuse.Reactive.FuseJS
{
	public class AuthenticationResult
	{
		public readonly string CallbackUrl;

		public AuthenticationResult(
			string callbackUrl)
		{
			CallbackUrl = callbackUrl;
		}
	}

	public static class WebAuthentication
	{
		public static Future<AuthenticationResult> Authenticate(
			string url,
			string callbackUrlScheme)
		{
			if defined(iOS)
			{
				return iOSWebAuthentication.Authenticate(url, callbackUrlScheme);
			}
			else
			{
				var promise = new Promise<AuthenticationResult>();
				promise.Reject(new Exception("Platform not supported"));
				return promise;
			}
		}
	}

	extern(iOS) static class iOSWebAuthentication
	{
		[Require("Xcode.Framework", "SafariServices")]
		[Require("Source.Include", "SafariServices/SafariServices.h")]
		class AuthenticationPromise : Promise<AuthenticationResult>
		{
			ObjC.Object _session;

			public AuthenticationPromise(
				string url,
				string callbackUrlScheme)
			{
				_session = Authenticate(url, callbackUrlScheme, OnSuccess, OnError);
			}

			[Foreign(Language.ObjC)]
			static ObjC.Object Authenticate(
				string url,
				string callbackUrlScheme,
				Action<string> onSuccess,
				Action<string> onError)
			@{
				SFAuthenticationSession* session = [[SFAuthenticationSession alloc]
					initWithURL:[NSURL URLWithString:url]
					callbackURLScheme:callbackUrlScheme
					completionHandler:^(NSURL* callbackUrl, NSError* error) {
						if (error != NULL) {
							onError([NSString stringWithFormat:@"%@", error]);
						} else {
							onSuccess(callbackUrl.absoluteString);
						}
					}];
    			[session start];
    			return session;
			@}

			void OnError(string errorMessage)
			{
				Reject(new Exception(errorMessage));
			}

			void OnSuccess(string callbackUrl)
			{
				Resolve(new AuthenticationResult(callbackUrl));
			}
		}

		public static Future<AuthenticationResult> Authenticate(
			string url,
			string callbackUrlScheme)
		{
			return new AuthenticationPromise(url, callbackUrlScheme);
		}
	}

	static class PromiseExtensions
	{
		public static Promise<T> RejectWithMessage<T>(this Promise<T> promise, string message)
		{
			promise.Reject(new Exception(message));
			return promise;
		}
	}

	[UXGlobalModule]
	public sealed class WebAuthenticationModule : NativeModule
	{
		static readonly WebAuthenticationModule _instance;

		public WebAuthenticationModule()
		{
			if(_instance != null)
				return;
			Resource.SetGlobalKey(_instance = this, "FuseJS/WebAuthentication");
			AddMember(new NativePromise<AuthenticationResult, string>("authenticate", Authenticate, ConvertAuthenticationResult));
		}

		static Future<AuthenticationResult> Authenticate(object[] args)
		{
			if (args.Length != 2)
				return new Promise<AuthenticationResult>().RejectWithMessage("Unexpected number of arguments");
			if (!(args[0] is string) || !(args[1] is string))
				return new Promise<AuthenticationResult>().RejectWithMessage("Arguments must be strings");

			var url = (string)args[0];
			var callbackUrlScheme = (string)args[1];
			return WebAuthentication.Authenticate(url, callbackUrlScheme);
		}

		static string ConvertAuthenticationResult(Context context, AuthenticationResult result)
		{
			return result.CallbackUrl;
		}
	}
}

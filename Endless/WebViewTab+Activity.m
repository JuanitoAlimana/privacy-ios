//
//  WebViewTab+Activity.m
//  OnionBrowser2
//
//  Created by Benjamin Erhart on 03.04.19.
//  Copyright © 2019 jcs. All rights reserved.
//

#import "WebViewTab+Activity.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import "URLInterceptor.h"

/**
 Tries to offer the currently open page in the most usable way to the user:

 - Images and audio/video will be offered as such and the user has the possibility
 to save to their camera roll.

 - Documents, like PDF, will be offered as NSData. The user will have the opportunity
 to save it to their iCloude drive or similar apps.

 - Markup will be offered as URLs.

 This is UNFINISHED WORK, therefore deactivated:
 It currently needs to re-download stuff, and that bypasses Tor. This is unaceptable.

 Interestingly enough, the "download image" feature doesn't bypass Tor, but that's
 a synchronous download. Not something we want to use here, since downloading a
 video could take a while and would block the UI in the meantime which cancels
 the ShareSheet.

 Unfortunately UIWebView doesn't have a proper API to grab anything else than HTML
 out of it. E.g. you cannot take a binary image or PDF directly out of its cache,
 you can just read out its URL from a made-up pseudo HTML.

 So the only way we currently see how to do that, is to actually build a
 full-fledged cache in URLInterceptor, which is out of scope for the moment.
 */
@implementation WebViewTab (Activity)

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
//	if (!self.downloadStarted)
//	{
//		// TODO: This bypasses Tor! Not ready for production!
//		NSURLSessionConfiguration *conf = NSURLSessionConfiguration.defaultSessionConfiguration;
//		conf.protocolClasses = @[[URLInterceptor class]];
//
//		NSURLSession *session = [NSURLSession sessionWithConfiguration:
//								 NSURLSessionConfiguration.defaultSessionConfiguration];
//
//		NSURLSessionDataTask *task = [session dataTaskWithURL:self.url completionHandler:
//									  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//										  NSLog(@"[%@] error=%@, data=%@", self.class, error, data);
//
//										  self.content = data;
//									  }];
//		// TODO: This bypasses Tor! Not ready for production!
////		[task resume];
//		self.downloadStarted = YES;
//	}
//
//	NSString *contentType = (__bridge_transfer NSString *)self.uti;
//
//	NSLog(@"[%@] contentType=%@", self.class, contentType);
//
//	if (self.isImageOrAv)
//	{
//		return [[UIImage alloc] init];
//	}
//
//	if (self.isDocument)
//	{
//		return [[NSData alloc] init];
//	}

	return self.url;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType
{
//	if (activityType == UIActivityTypePrint) {
//		return self.content;
//	}
//	else if (activityType == UIActivityTypeMarkupAsPDF) {
//		if (self.isText)
//		{
//			return self.content;
//		}
//	}
//	else if (activityType == UIActivityTypeMail) {
//		if (self.isDocument)
//		{
//			return self.content;
//		}
//
//		return self.url;
//	}
//	else if (activityType == UIActivityTypeOpenInIBooks)
//	{
//		if (self.isDocument)
//		{
//			return self.content;
//		}
//	}
//	else if (activityType == UIActivityTypeAirDrop
//		|| activityType == UIActivityTypeCopyToPasteboard)
//	{
//		if (!self.isMarkup)
//		{
//			return self.content;
//		}
//
//		return self.url;
//	}
//	else if (activityType == UIActivityTypeSaveToCameraRoll)
//	{
//		if (self.isImageOrAv)
//		{
//			return self.content;
//		}
//	}
//	else if (activityType == UIActivityTypeMessage
//		|| activityType == UIActivityTypePostToVimeo
//		|| activityType == UIActivityTypePostToWeibo
//		|| activityType == UIActivityTypePostToFlickr
//		|| activityType == UIActivityTypePostToTwitter
//		|| activityType == UIActivityTypePostToFacebook
//		|| activityType == UIActivityTypePostToTencentWeibo)
//	{
//		if (self.isImageOrAv) {
//			return self.content;
//		}
//
//		return self.url;
//	}
//
//	if (activityType == UIActivityTypeAssignToContact
//		|| activityType == UIActivityTypeAddToReadingList)
//	{
		return self.url;
//	}
//
//	return nil;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType
{
	return self.title.text;
}

- (nullable UIImage *)activityViewController:(UIActivityViewController *)activityViewController
			   thumbnailImageForActivityType:(nullable UIActivityType)activityType
							   suggestedSize:(CGSize)size
{
	UIGraphicsBeginImageContext(self.webView.bounds.size);
	[self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return thumbnail;
}

- (CFStringRef)uti
{
	NSString *type = [self.webView stringByEvaluatingJavaScriptFromString:@"document.contentType"];

	return UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType,
												 (__bridge CFStringRef) type,
												 nil);
}

- (BOOL)isImageOrAv
{
	CFStringRef uti = self.uti;

	Boolean isImageOrAv = UTTypeConformsTo(uti, kUTTypeImage)
		|| UTTypeConformsTo(uti, kUTTypeAudiovisualContent);

	CFRelease(uti);

	return !!isImageOrAv;
}

- (BOOL)isDocument
{
	CFStringRef uti = self.uti;

	Boolean isDocument = UTTypeConformsTo(uti, kUTTypeData)
		&& !UTTypeConformsTo(uti, kUTTypeHTML)
		&& !UTTypeConformsTo(uti, kUTTypeXML);

	CFRelease(uti);

	return !!isDocument;
}

- (BOOL)isText
{
	CFStringRef uti = self.uti;

	Boolean isText = UTTypeConformsTo(uti, kUTTypeText);

	CFRelease(uti);

	return !!isText;
}

- (BOOL)isMarkup
{
	CFStringRef uti = self.uti;

	Boolean isMarkup = UTTypeConformsTo(uti, kUTTypeHTML)
		|| UTTypeConformsTo(uti, kUTTypeXML);

	CFRelease(uti);

	return !!isMarkup;
}

- (NSData *)content
{
	return objc_getAssociatedObject(self, @selector(content));
}

- (void)setContent:(NSData *)content
{
	objc_setAssociatedObject(self, @selector(content), content,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)downloadStarted
{
	NSNumber *number = objc_getAssociatedObject(self, @selector(downloadStarted));

	return number.boolValue;
}

- (void)setDownloadStarted:(BOOL)downloadStarted
{
	objc_setAssociatedObject(self, @selector(downloadStarted),
							 [NSNumber numberWithBool:downloadStarted],
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

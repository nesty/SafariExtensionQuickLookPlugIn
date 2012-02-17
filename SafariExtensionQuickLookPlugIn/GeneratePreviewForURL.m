#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Cocoa/Cocoa.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

CFDataRef extensionThumbnailData(CFStringRef extensionFolderPath);
CFStringRef extractExtension(CFURLRef url);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    CFStringRef extensionFolderPath = extractExtension(url);
    
    NSString *extensionPropertyListPath = [(__bridge NSString *)extensionFolderPath stringByAppendingString:@"Info.plist"];
    NSDictionary *extensionPropertyList = [NSDictionary dictionaryWithContentsOfFile:extensionPropertyListPath];
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
    [properties setObject:@"text/html" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
    
    NSMutableDictionary *imageProperties = [[NSMutableDictionary alloc] init];
    [imageProperties setObject:@"image/png" forKey:(NSString *)kQLPreviewPropertyMIMETypeKey];
    [imageProperties setObject:(__bridge NSData *)extensionThumbnailData(extensionFolderPath) forKey:(NSString *)kQLPreviewPropertyAttachmentDataKey];
    
    [properties setObject:[NSDictionary dictionaryWithObject:imageProperties forKey:@"thumbnail.png"] forKey:(NSString *)kQLPreviewPropertyAttachmentsKey];
    
    NSString *html = [NSString stringWithFormat:@"<style>body {font-family: 'Lucida Grande'; font-size: 14px; color: #222; background: #F1F1F1;} h1 {margin-top: 25px; margin-bottom: 19px; font-size: 20px;} img {float: left; margin-right: 35px;}</style><img src='cid:thumbnail.png'><h1>%@</h1> Safari extension<br><br> Version %@<br><br> Author: %@<br><br> %@<br>", [extensionPropertyList objectForKey:@"CFBundleDisplayName"], [extensionPropertyList objectForKey:@"CFBundleShortVersionString"], [extensionPropertyList objectForKey:@"Author"], [extensionPropertyList objectForKey:@"Description"]];
    
    QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], kUTTypeHTML, (__bridge CFDictionaryRef)properties);
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}

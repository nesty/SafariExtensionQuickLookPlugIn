#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

CFDataRef extensionThumbnailData(CFStringRef extensionFolderPath);
CFStringRef extractExtension(CFURLRef url);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    // extracting extension
    CFStringRef extensionFolderPath = extractExtension(url);
    
    // creating thumbnail
    CGImageSourceRef thumbnailImageSource = CGImageSourceCreateWithData(extensionThumbnailData(extensionFolderPath), NULL);
    CGImageRef thumbnailImage = CGImageSourceCreateImageAtIndex(thumbnailImageSource, 0, NULL);
    QLThumbnailRequestSetImage(thumbnail, thumbnailImage, NULL);
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}

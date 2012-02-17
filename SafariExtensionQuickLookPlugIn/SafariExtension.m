//
//  SafariExtension.m
//  SafariExtensionQuickLookPlugIn
//
//  Created by Michael Gunder on 2/17/12.
//

#import <Cocoa/Cocoa.h>

CFDataRef extensionThumbnailData(CFStringRef extensionFolderPath);
CFStringRef extractExtension(CFURLRef url);
CFStringRef extensionIconPath(CFStringRef extensionFolderPath);

CFStringRef extensionIconPath(CFStringRef extensionFolderPath) {
    NSArray *iconFileNames = [NSArray arrayWithObjects:@"Icon-64.png", @"Icon.png", @"icon.png", @"Icon-96.png", @"Icon-128.png", nil];
    
    for (NSString *iconFileName in iconFileNames) {
        NSString *iconPath = [(__bridge NSString *)extensionFolderPath stringByAppendingFormat:iconFileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
            return (__bridge CFStringRef)iconPath;
        }
    }
    
    return nil;
}

CFDataRef extensionThumbnailData(CFStringRef extensionFolderPath) {
    CFStringRef iconPath = extensionIconPath(extensionFolderPath);
    
    NSImage *extensionIconImage = [[NSImage alloc] initWithContentsOfFile:(__bridge NSString *)iconPath];
    NSImage *safariExtensionIconImage = [[NSImage alloc] initWithContentsOfFile:@"/Applications/Safari.app/Contents/Resources/safariextz.icns"];
    
    [extensionIconImage setSize:NSMakeSize(64, 64)];
    [safariExtensionIconImage setSize:NSMakeSize(256, 256)];
    
    NSImage *thumbnailImage = [[NSImage alloc] initWithSize:NSMakeSize(256, 256)];
    [thumbnailImage lockFocus];
    [safariExtensionIconImage compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
    [extensionIconImage compositeToPoint:NSMakePoint(47, 82) operation:NSCompositeSourceOver];
    [thumbnailImage unlockFocus];
    
    return (__bridge CFDataRef)[thumbnailImage TIFFRepresentation];
}

CFStringRef extractExtension(CFURLRef url) {
    NSString *extensionPath = [(__bridge NSURL *)url path];
    NSString *extractionPath = [NSTemporaryDirectory() stringByAppendingFormat:@"net.projectdot.SafariExtensionQuickLookPlugIn/"];
    
    BOOL directory = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:extractionPath isDirectory:&directory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:extractionPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    
    NSArray *extractionArguments = [NSArray arrayWithObjects:@"-x", @"-v", @"-f", extensionPath, @"-C", extractionPath, nil];
    
    NSPipe *extractionOutputPipe = [NSPipe pipe];
    NSFileHandle *extractionOutputHandle = [extractionOutputPipe fileHandleForReading];
    
    NSTask *extractionTask = [[NSTask alloc] init];
    [extractionTask setArguments:extractionArguments];
    [extractionTask setLaunchPath:@"/usr/bin/xar"];
    [extractionTask setStandardOutput:extractionOutputPipe];
    [extractionTask launch];
    
    NSMutableData *extractionOutputData = [[NSMutableData alloc] init];
    NSData *readOutputData;
    
    while ((readOutputData = [extractionOutputHandle availableData]) && [readOutputData length]) {
        [extractionOutputData appendData:readOutputData];
    }
    
    NSString *extractedOutputString = [[NSString alloc] initWithData:extractionOutputData encoding:NSUTF8StringEncoding];
    NSArray *extractedOutputLines = [extractedOutputString componentsSeparatedByString:@"\n"];
    
    NSString *extractedExtensionFolderName = [extractedOutputLines objectAtIndex:[extractedOutputLines count] - 2];
    NSString *extractedExtensionFolderPath = [NSString stringWithFormat:@"%@%@/", extractionPath, extractedExtensionFolderName];
    
    return (__bridge CFStringRef)extractedExtensionFolderPath;
}

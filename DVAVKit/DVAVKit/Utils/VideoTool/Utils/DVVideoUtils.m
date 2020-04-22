//
//  DVVideoUtils.m
//  DVAVKit
//
//  Created by DV on 2019/4/1.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVVideoUtils.h"
#import <VideoToolbox/VideoToolbox.h>

@interface DVVideoUtils ()

@property(nonatomic, copy) void(^completionBlock)(BOOL finished);

@end


@implementation DVVideoUtils

+ (UIImage *)convertToImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    // Get the number of bytes per row for the plane pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent gray color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaNone);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
    
}

+ (UIImage *)uiImageFromPixelBuffer:(CVPixelBufferRef)p {
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:p];
    
    CIContext* context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(p), CVPixelBufferGetHeight(p));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    
    UIImage* image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}


#pragma mark - <-- 保存视频 -->
+ (void)saveVideoToPhotoAlbum:(NSString *)filePath completion:(void (^)(BOOL))completion {
    NSParameterAssert(completion);
    
    DVVideoUtils *untils = [[DVVideoUtils alloc] init];
    untils.completionBlock = completion;
    [untils saveVideoToPhotoAlbum:filePath];
}

- (void)saveVideoToPhotoAlbum:(NSString *)filePath {
    BOOL ret = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath);
    
    if (ret) {
        UISaveVideoAtPathToSavedPhotosAlbum(filePath,
                                            self,
                                            @selector(video:didFinishSavingWithError:contextInfo:),
                                            nil);
    } else {
        NSLog(@"[DVVideoUtils ERROR]: 无法识别视频格式, 保存至相册失败 -> %@", filePath);
        self.completionBlock(NO);
        self.completionBlock = nil;
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    BOOL ret = NO;
    
    do {
        if (error) {
            NSLog(@"[DVVideoUtils ERROR]: 保存视频到系统相册失败 URL-> %@, error-> %@", videoPath, error.localizedDescription);
            break;
        }
        
        NSLog(@"[DVVideoUtils ERROR]: 保存视频到系统相册成功-> %@", videoPath);
        ret = YES;
        
    } while (NO);
    
    self.completionBlock(ret);
    self.completionBlock = nil;
}


#pragma mark - <-- 保存图片 -->
+ (void)saveImageToPhotoAlbum:(UIImage *)image completion:(void (^)(BOOL))completion {
    NSParameterAssert(completion);
    NSParameterAssert(image);
    
    DVVideoUtils *untils = [[DVVideoUtils alloc] init];
    untils.completionBlock = completion;
    [untils saveImageToPhotoAlbum:image];
}

- (void)saveImageToPhotoAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    BOOL ret = NO;
    
    do {
        if (error) {
            NSLog(@"[DVVideoUtils ERROR]: 保存图片到系统相册失败-> %@",error.localizedDescription);
            break;
        }
        
        NSLog(@"[DVVideoUtils ERROR]: 保存图片到系统相册成功");
        ret = YES;
        
    } while (NO);
    
    self.completionBlock(ret);
    self.completionBlock = nil;
}

@end

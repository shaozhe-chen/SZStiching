//
//  SZImageFinger.m
//  SZStiching
//  指纹提取类
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZImageFinger.h"
#import <zlib.h>
#define P_ADD 8
#define P_SEPARATOR 3
@interface SZImageFinger ()
@property (nonatomic,assign) SZImageFingerType type;
@property (nonatomic, strong) NSArray *firstArray;
@property (nonatomic, strong) NSArray *secondArray;
@property (nonatomic, strong) NSArray *thirdArray;
@end

@implementation SZImageFinger
+ (instancetype)fingerImage:(UIImage *)image type:(SZImageFingerType)type{
    SZImageFinger *finger = [SZImageFinger new];
    finger.type = type;
    [finger fingerImage:image];
    return finger;
}

- (void)fingerImage:(UIImage *)image{
    _lines = [NSMutableArray array];
    if (self.type == SZImageFingerTypeCRC) {
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        [self crcFingerImage:image];
        CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
        NSLog(@"mini提取指纹耗费时间：%@",@(nextTime));
    }
    else if (self.type == SZImageFingerTypeMin){
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        [self minMutlQueueFingerImage:image];
        CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
        NSLog(@"crc提取指纹耗费时间：%@",@(nextTime));
    }
//    else if (self.type == SZImageFingerType32Min){
//        [self min32FingerImage:image];
//    }

}

//crc精确提取指纹
- (void)crcFingerImage:(UIImage *)image{
    @autoreleasepool {
        NSMutableArray *array = [NSMutableArray array];
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        const UInt8* data = CFDataGetBytePtr(pixelData);
        NSInteger height = image.size.height;
        NSInteger width = image.size.width;
        NSInteger alla = CFDataGetLength(pixelData);
        NSInteger scale = alla/(height*width);
        for (NSInteger y = 0; y < height; y++)
        {
             @autoreleasepool {
                NSData *cacheData = [NSData dataWithBytes:data + y * width * scale
                                                   length:width * scale];
                uLong print = crc32(0, [cacheData bytes], (uInt)[cacheData length]);
                [array addObject:@(print)];
             }
        }
        _lines = array;
        CFRelease(pixelData);
    }
}

- (void)minMutlQueueFingerImage:(UIImage *)image
{
    @autoreleasepool {
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
//        const UInt8* data = CFDataGetBytePtr(pixelData);
        NSInteger alla = CFDataGetLength(pixelData);
        NSInteger scale = alla/(image.size.width * image.size.height);
        UInt8 *data = (UInt8 *)[self pixelBRGABytesFromImageRef:image.CGImage scale:scale imageLength:alla];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("come.sz.nb", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, queue, ^{
            [self miniHalfFingerImage:image index:0 data:data all:alla];
        });
        dispatch_group_async(group, queue, ^{
             [self miniHalfFingerImage:image index:image.size.height/P_SEPARATOR data:data all:alla];
        });
        dispatch_group_async(group, queue, ^{
             [self miniHalfFingerImage:image index:image.size.height*2/P_SEPARATOR data:data all:alla];
        });
        dispatch_group_notify(group, queue, ^{
            [self.lines addObjectsFromArray:self.firstArray];
            [self.lines addObjectsFromArray:self.secondArray];
            [self.lines addObjectsFromArray:self.thirdArray];
            CFRelease(pixelData);
            free(data);
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
}

- (void)miniHalfFingerImage:(UIImage *)image index:(NSInteger)index data:(const UInt8 *)data all:(NSInteger)all{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger height = image.size.height;
    NSInteger width = image.size.width;
    NSInteger scale = all/(height*width);
    NSInteger startIndex = index;
    NSInteger endIndex = startIndex == 0 ? height/P_SEPARATOR : (startIndex == height/P_SEPARATOR ? height * 2 / P_SEPARATOR : height);
    for (NSInteger y = startIndex; y < endIndex; y++) {
         @autoreleasepool {
            NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
            for (NSInteger x = 0; x < width; x++) {
                if (x % 4 == 0) {
                    const UInt8 *pixel = &(data[y * width * scale + x * scale]);
                    int32_t gray = 0.3 * pixel[2] + 0.59 * pixel[1] + 0.11 * pixel[0];
                    if (map[@(gray)] == nil) {
                        map[@(gray)] = @(1);
                    }else {
                        map[@(gray)] = @([map[@(gray)] integerValue] + 1);
                    }
                }
            }
            
            NSInteger count = [map.allKeys count];
            NSInteger averge = 0;
            NSInteger sum = 0;
            for (NSNumber *key in map.allKeys) {
                NSInteger value = key.integerValue;
                sum += value;
            }
            averge = sum/count;
            [array addObject:@(averge)];
         }
    }
    
    if (index == 0) {
        _firstArray = array;
    }
    else if (index == height/P_SEPARATOR) {
        _secondArray = array;
    }
    else if (index == height*2/P_SEPARATOR) {
        _thirdArray = array;
    }
}

- (void)minFingerImage:(UIImage *)image {
    
    NSMutableArray *array = [NSMutableArray array];
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    NSInteger height = image.size.height;
    NSInteger width = image.size.width;
    NSInteger alla = CFDataGetLength(pixelData);
    NSInteger scale = alla/(height*width);
    for (NSInteger y = 0; y < height; y++)
    {
        NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
        for (NSInteger x = 0; x < width; x++)
        {
            if (x % 4 == 0) {
                const UInt8 *pixel = &(data[y * width * scale + x * scale]);
                int32_t gray = 0.3 * pixel[3] + 0.59 * pixel[2] + 0.11 * pixel[1];
                
                const UInt8 *pixel_next = &(data[y * width * scale + (x+16) * scale]);
                int32_t gray_next = 0.3 * pixel_next[3] + 0.59 * pixel_next[2] + 0.11 * pixel_next[1];
                
                if (map[@(gray)] == nil)
                {
                    map[@(gray)] = @(1);
                }
                else
                {
                    map[@(gray)] = @([map[@(gray)] integerValue] + 1);
                }
                
                if (map[@(gray_next)] == nil)
                {
                    map[@(gray_next)] = @(1);
                }
                else
                {
                    map[@(gray_next)] = @([map[@(gray_next)] integerValue] + 1);
                }
            }
            
        }
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSNumber *key in map.allKeys)
        {
            NSValue *value = [NSValue valueWithRange:NSMakeRange([key integerValue], [map[key] integerValue])];
            [numbers addObject:value];
        }
        
        NSInteger count = [numbers count];
        NSInteger averge = 0;
        NSInteger sum = 0;
        for (NSInteger i = 0; i < count; i++)
        {
            NSInteger value = [numbers[i] rangeValue].location;
            sum += value;
        }
        averge = sum/count;
        [array addObject:@(averge)];
    }
    _lines = array;
    CFRelease(pixelData);
}

- (void)min32FingerImage:(UIImage *)image{

    NSInteger height = image.size.height;
    NSInteger width = image.size.width;
    NSMutableArray *mLines = [NSMutableArray array];
    CFDataRef pixeData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    NSInteger all = CFDataGetLength(pixeData);
    CGFloat scale = all/(image.size.width * image.size.height);
    UInt8 *pixels = (UInt8 *)[self pixelBRGABytesFromImageRef:image.CGImage scale:scale imageLength:all];
    for (NSInteger y = 0; y < height; y++) {
        NSMutableDictionary *map = [NSMutableDictionary new];
        for (NSInteger x = 0; x < width; x++) {
            //取一个像素点
            const uint8_t *rgbaPixel = (uint8_t*) &pixels[y * width + x];
            //计算灰度值
            int32_t gray = 0.3*rgbaPixel[3] + 0.59*rgbaPixel[2] + 0.11*rgbaPixel[1];
            if (map[@(gray)] == nil) {
                map[@(gray)] = @1;
            }
            else{
                //统计相同灰度值出现的次数
                map[@(gray)] = @([map[@(gray)] integerValue] + 1);
            }
        }
        //字典转NSValue
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSNumber *key in map.allKeys)
        {
            NSValue *value = [NSValue valueWithRange:NSMakeRange([key integerValue], [map[key] integerValue])];
            [numbers addObject:value];
        }
//        //升序，出现次数少的灰度值排在前面
//        [numbers sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//            NSInteger first = [obj1 rangeValue].length;
//            NSInteger second = [obj2 rangeValue].length;
//            return  first < second ? NSOrderedAscending : NSOrderedDescending;
//        }];

        NSInteger count = [numbers count];
        NSInteger averge = 0;
        NSInteger sum = 0;
        //取最小的灰度值
        for (NSInteger i = 0; i < count; i++)
        {
            NSInteger value = [numbers[i] rangeValue].location;
            sum += value;
        }
        averge = sum/count;
        [mLines addObject:@(averge)];
    }
    _lines = mLines.copy;
    free(pixels);
}

- (uint32_t *)pixelBRGABytesFromImageRef:(CGImageRef)imageRef scale:(NSInteger) scale imageLength:(CGFloat) length{

    NSUInteger iWidth = CGImageGetWidth(imageRef);
    NSUInteger iHeight = CGImageGetHeight(imageRef);
    NSUInteger iBytesPerPixel = scale;
    NSUInteger iBytesPerRow = iBytesPerPixel * iWidth;
    NSUInteger iBitsPerComponent = 8;
    uint32_t *pixels = (uint32_t*) malloc(length);
     memset(pixels,0, length);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,imageRef);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    
    return pixels;
}

@end

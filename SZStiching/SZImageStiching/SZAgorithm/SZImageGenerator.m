//
//  SZImageGenerator.m
//  SZStiching
//  图片生成器
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZImageGenerator.h"
#import "SZImageMergeInfo.h"
#import "SZConstraint.h"
#import "UIImage+Stiching.h"

@interface SZImageGenerator ()
@property (nonatomic, strong) UIImage *firstImage;
@property (nonatomic, strong) UIImage *crcFirstImage;
@property (nonatomic, strong) UIImage *minFirstImage;
@property (nonatomic, strong) NSMutableArray *crcInfos;
@property (nonatomic, strong) NSMutableArray *minInfos;

@property (nonatomic, strong) SZImageMergeInfo *crcMergeInfo;
@property (nonatomic, strong) SZImageMergeInfo *miniMergeInfo;
@end


@implementation SZImageGenerator
- (instancetype)init{
    if (self = [super init]) {
        _infos = @[].mutableCopy;
        _crcInfos = @[].mutableCopy;
        _minInfos = @[].mutableCopy;
    }
    return self;
}

- (BOOL)feedImages:(NSArray *)images{
   
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.image.loop.nb", DISPATCH_QUEUE_CONCURRENT);
    for (UIImage *image in images)
    {
        @autoreleasepool
        {
            dispatch_group_async(group, queue, ^{
                [self crcFeedImage:image];
            });
            dispatch_group_async(group, queue, ^{
                [self minFeedImage:image];
            });
            dispatch_group_notify(group, queue, ^{
                SZImageMergeInfo *crcInfo = self.crcInfos.lastObject;
                SZImageMergeInfo *minInfo = self.minInfos.lastObject;
                if (!crcInfo.error) {
                    [self.infos addObject:crcInfo];
                }
                else if (!minInfo.error) {
                    [self.infos addObject:minInfo];
                }
                else {
                    [self.infos addObject:crcInfo];
                }
                dispatch_semaphore_signal(sema);
            });
            [self.crcInfos removeAllObjects];
            [self.minInfos removeAllObjects];
            _crcInfos = nil;
            _crcInfos = nil;
        }
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
   
    return YES;
}

- (BOOL)feedImage:(UIImage *)image{
    if (image)
    {
        if (!_minFirstImage || !_crcFirstImage) {
            _crcFirstImage = image;
            _minFirstImage = image;
            return YES;
        }
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("com.image.loop.nb", DISPATCH_QUEUE_CONCURRENT);
            @autoreleasepool
            {
                dispatch_group_async(group, queue, ^{
                    [self crcFeedImage:image];
                });
                dispatch_group_async(group, queue, ^{
                    [self minFeedImage:image];
                });
                dispatch_group_notify(group, queue, ^{
                    SZImageMergeInfo *crcInfo = self.crcInfos.lastObject;
                    SZImageMergeInfo *minInfo = self.minInfos.lastObject;
                    if (!crcInfo.error) {
                        [self.infos addObject:crcInfo];
                    }
                    else if (!minInfo.error) {
                        [self.infos addObject:minInfo];
                    }
                    else {
                        [self.infos addObject:crcInfo];
                    }
                    dispatch_semaphore_signal(sema);
                });
            }
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    return YES;
}

- (void)crcFeedImage:(UIImage *)image {
    UIImage *baseImage = [self crcBaseImage];
    SZImageMergeInfo *info = [self.crcMergeInfo infoBy:baseImage
                                            secondImage:image
                                                   type:SZImageFingerTypeCRC];
    BOOL success =[info validInfo:info];
    
    if (!success) {
        if (info.firstOffset > info.secondOffset) {
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotSort
                                     userInfo:nil];
        }
        else{
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotEnoughOverlap
                                     userInfo:nil];
        }
        //如果不成功，会添加error的信息，用这个来判断是否需要拼接。
        info.error = _error;
    }
    //不管成功与否，都添加到数组中
    [_crcInfos addObject:info];
}

- (void)minFeedImage:(UIImage *)image {
    UIImage *baseImage = [self minBaseImage];
    SZImageMergeInfo *info = [self.miniMergeInfo infoBy:baseImage
                                            secondImage:image
                                                   type:SZImageFingerTypeMin];
    BOOL success =[info validInfo:info];
    
    if (!success) {
        if (info.firstOffset > info.secondOffset) {
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotSort
                                     userInfo:nil];
        }
        else{
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotEnoughOverlap
                                     userInfo:nil];
        }
        //如果不成功，会添加error的信息，用这个来判断是否需要拼接。
        info.error = _error;
    }
    //不管成功与否，都添加到数组中
    [_minInfos addObject:info];
}

- (void)doFeedImage:(UIImage *)image
{
    UIImage *baseImage = [self baseImage];
    SZImageMergeInfo *info = [self.miniMergeInfo infoBy:baseImage
                                            secondImage:image
                                                   type:SZImageFingerTypeMin];
    BOOL success =[info validInfo:info];
    
//    if (!success)
//    {
//        //识别重试的时候，需要手动清除上一次最大偏移量的记录，不然会出错。
//        [SZImageMergeInfo clear];
//        // CRC 这种较严格匹配失败的话，尝试下比较宽松的匹配 （容易出现误匹配
//        info = [SZImageMergeInfo infoBy:baseImage
//                             secondImage:image
//                                    type:HXImageFingerTypeMin];
//        success = [self validInfo:info];
//    }

    if (!success) {
        if (info.firstOffset > info.secondOffset) {
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotSort
                                     userInfo:nil];
        }
        else{
            _error = [NSError errorWithDomain:SZERRORDOMAIN
                                         code:SZMergeErrorNotEnoughOverlap
                                     userInfo:nil];
        }
        //如果不成功，会添加error的信息，用这个来判断是否需要拼接。
        info.error = _error;
    }
    //不管成功与否，都添加到数组中
    [_infos addObject:info];
}


- (UIImage *)generate
{
    if ([_infos count] == 0)
    {
        return nil;
    }
    
#if DEBUG
    
    {
        NSString *path = NSTemporaryDirectory();
        NSString *prefix = [NSString stringWithFormat:@"%@",[NSDate date]];
        NSLog(@"view images at %@ with prefix %@",path,prefix);
        for (NSInteger i = 0; i < [_infos count]; i++)
        {
            SZImageMergeInfo *info = [_infos objectAtIndex:i];
            UIImage *firstImage = [info.firstImage hx_rangedImage:NSMakeRange(info.firstOffset, info.length)];
            NSString *firstImagePath = [NSString stringWithFormat:@"%@/%@_%zd_first.png",path,prefix,i];
            [firstImage hx_saveAsPngFile:firstImagePath];
            
            
            UIImage *secondImage = [info.secondImage hx_rangedImage:NSMakeRange(info.secondOffset, info.length)];
            NSString *secondImagePath = [NSString stringWithFormat:@"%@/%@_%zd_second.png",path,prefix,i];
            [secondImage hx_saveAsPngFile:secondImagePath];
        }
    }
    
#endif
    
    SZImageMergeInfo *drawInfo = [_infos firstObject];
    [_infos removeObjectAtIndex:0];
    
    UIImage *result = nil;
    while (drawInfo)
    {
        @autoreleasepool
        {
            UIImage *firstImage = drawInfo.firstImage;
            UIImage *secondImage= drawInfo.secondImage;
            NSRange firstRange = NSMakeRange(firstImage.size.height - drawInfo.firstOffset, drawInfo.length);
            NSRange secondRange= NSMakeRange(secondImage.size.height - drawInfo.secondOffset, drawInfo.length);
            
            CGSize size = CGSizeMake(drawInfo.firstImage.size.width, firstRange.location + drawInfo.secondOffset);
            CGFloat scale = drawInfo.firstImage.scale;
            
            UIGraphicsBeginImageContextWithOptions(size, NO, scale);
            CGRect firstImageRect = CGRectMake(0, 0, firstImage.size.width, firstImage.size.height);
            [firstImage drawInRect:firstImageRect];
            CGRect subSecondImageRect = CGRectMake(0, secondRange.location, secondImage.size.width, drawInfo.secondOffset);
            UIImage *subSecondImage = [secondImage hx_subImage:subSecondImageRect];
             CGRect secondRect = CGRectMake(0, firstRange.location, size.width, subSecondImage.size.height);
            [subSecondImage drawInRect:secondRect];
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            [self toDrawRect:CGRectMake(0, drawInfo.secondOffset, size.width, drawInfo.length) color:[UIColor blueColor]
//                     context:context];
//            [self toDrawRect:CGRectMake(0, drawInfo.firstOffset, size.width, drawInfo.length) color:[UIColor redColor] context:context];
            result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            drawInfo = nil;
            
            if ([_infos count])
            {
                SZImageMergeInfo *info = [_infos firstObject];
                [_infos removeObjectAtIndex:0];
                info.firstImage = result;
                drawInfo = info;
            }
            
        }
    }
    return result;
}

- (void)toDrawRect:(CGRect)rectangle color:fillColor context:(CGContextRef)ctx{
    
    //创建路径并获取句柄
    CGMutablePathRef
    path = CGPathCreateMutable();
    //将矩形添加到路径中
    CGPathAddRect(path,NULL,
                  rectangle);
    
    //获取上下文
    //将路径添加到上下文
    
    CGContextAddPath(ctx,
                     path);
    
    //设置矩形填充色
    [[UIColor clearColor] setFill];
    //矩形边框颜色
    [fillColor setStroke];
    //边框宽度
    CGContextSetLineWidth(ctx,10);
//    CGFloat lengths[] = {10,10};
//    CGContextSetLineDash(ctx, 10, lengths,20);
    //绘制
    CGContextDrawPath(ctx,
                      kCGPathFillStroke);
    CGPathRelease(path);
}

- (UIImage *)baseImage
{
    UIImage *image  = nil;
    SZImageMergeInfo *info = [_infos lastObject];
    if (info)
    {
        image = info.secondImage;
    }
    else
    {
        image = _firstImage;
    }
    return image;
}

- (UIImage *)crcBaseImage
{
    UIImage *image  = nil;
    SZImageMergeInfo *info = [_crcInfos lastObject];
    if (info)
    {
        image = info.secondImage;
    }
    else
    {
        image = _crcFirstImage;
    }
    return image;
}

- (UIImage *)minBaseImage
{
    UIImage *image  = nil;
    SZImageMergeInfo *info = [_minInfos lastObject];
    if (info)
    {
        image = info.secondImage;
    }
    else
    {
        image = _minFirstImage;
    }
    return image;
}

- (SZImageMergeInfo *)crcMergeInfo {
    if (!_crcMergeInfo) {
        _crcMergeInfo = [SZImageMergeInfo new];
    }
    return _crcMergeInfo;
}

- (SZImageMergeInfo *)miniMergeInfo {
    if (!_miniMergeInfo) {
        _miniMergeInfo = [SZImageMergeInfo new];
    }
    return _miniMergeInfo;
}
@end

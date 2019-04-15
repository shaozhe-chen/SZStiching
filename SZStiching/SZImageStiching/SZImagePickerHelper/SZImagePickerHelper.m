//
//  SZImagePickerHelper.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZImagePickerHelper.h"
#import "CTAssetsPickerController.h"
#import "SZImageGenerator.h"
#import "SZImageMergeInfo.h"
#import "SZImagePreVewController.h"

typedef void(^SZImageMergeBlock)(SZImageGenerator *generator,NSError *error);
@interface SZImagePickerHelper ()<CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *selectAsset;
@property (nonatomic, assign) NSInteger alreadySelectCount;
@property (nonatomic,strong) dispatch_queue_t queue;
@end

@implementation SZImagePickerHelper

- (instancetype)init
{
    if (self = [super init])
    {
        _queue = dispatch_queue_create("com.chenshaozhe.image.queue", 0);
        _alreadySelectCount = 0;
    }
    return self;
}


#pragma mark - 选择图片
- (void)chooseImages
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                picker.showsSelectionIndex = YES;
                picker.showsNumberOfAssets = YES;
                if (self.selectAsset != nil) {
                   picker.selectedAssets = self.selectAsset.mutableCopy;
                }
                
                picker.delegate = self;
                
                if ([self.delegate respondsToSelector:@selector(presentViewController:animated:completion:)]) {
                    [self.delegate presentViewController:picker
                                                animated:YES
                                              completion:nil];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(photosRequestAuthorizationFailed)]) {
                    [self.delegate photosRequestAuthorizationFailed];
                }
            }
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [_selectAsset removeAllObjects];
    _selectAsset = [NSMutableArray arrayWithArray:assets];
    _alreadySelectCount = assets.count;
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   [self mergeImages:assets
                                          completion:^(SZImageGenerator *generator, NSError *error) {
                                              generator.error = error;
                                              if ([self.delegate respondsToSelector:@selector(showResult:)]) {
                                                  [self.delegate showResult:generator];
                                              }
                                          }];
                                   
                               }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didSelectAsset:(PHAsset *)asset {
    _alreadySelectCount ++;
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didDeselectAsset:(PHAsset *)asset {
    _alreadySelectCount --;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    if (_alreadySelectCount >= NORMAL_IMAGE_COUNT) {
        if (self.alreadySelectImageMaxCount) {
            self.alreadySelectImageMaxCount();
        }
        return NO;
    }
    return YES;
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}


#pragma mark - 合并图片
- (void)mergeImages:(NSArray *)assets
         completion:(SZImageMergeBlock)completion
{
        if ([self.delegate respondsToSelector:@selector(mergeBegin)]) {
           [self.delegate mergeBegin];
        }
        
        dispatch_async(_queue, ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            SZImageGenerator *generator = [self imageGeneratorBy:assets];
            if (!generator) {
                return ;
            }
            NSError *error = [generator error];
            CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
            NSLog(@"合并时间%@",@(nextTime));
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(mergeEnd)]) {
                   [self.delegate mergeEnd];
                }
                
                if (completion) {
                    generator.stiching = NO;
                    completion(generator,error);
                }
            });
        });
}

/*
 * @description assets数组生成获取图片，并开始合并
 */
- (SZImageGenerator *)imageGeneratorBy:(NSArray *)assets
{
    NSArray<UIImage *> *images = @[].copy;
    //先回到到控制器显示
    if (self.chooseImagesComplete) {
       images = self.chooseImagesComplete(assets);
    }
    if (!images.count) {
        return nil;
    }

    SZImageGenerator *generator = [[SZImageGenerator alloc] init];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    for (UIImage *image in images)
    {
        [generator feedImage:image];
    }
    
    CFAbsoluteTime next = CFAbsoluteTimeGetCurrent() - time;
    NSLog(@"总共消耗的时间：%@",@(next));
    return generator;
}

/*
 * 清除图片
 */
- (void)clearOriginAssets {
    [self.selectAsset removeAllObjects];
    _alreadySelectCount = 0;
}

//校验图片的合法性
- (BOOL)validAssets:(NSArray *)assets
{
    BOOL valid = [assets count] > 1;
    NSUInteger pixelWidth = 0;
    if (valid)
    {
        for (PHAsset *asset in assets)
        {
            if ([asset mediaType] != PHAssetMediaTypeImage)
            {
                valid = NO;
                break;
            }
            if ([asset pixelWidth] != pixelWidth)
            {
                if (pixelWidth == 0)
                {
                    pixelWidth = [asset pixelWidth];
                }
                else
                {
                    valid = NO;
                    break;
                }
            }
            
        }
    }
    return valid;
}

@end

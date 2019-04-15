//
//  SZMergeResult.m
//  SZMergeResult
//
//  Created by amao on 2017/1/4.
//  Copyright © 2017年 M80. All rights reserved.
//

#import "SZMergeResult.h"
#import "UIView+Toast.h"

@import Photos;

@implementation SZMergeResult
+ (instancetype)resultBy:(UIImage *)image
                   error:(NSError *)error
                  assets:(NSArray *)assets
{
    SZMergeResult *result = [[SZMergeResult alloc] init];
    result.image = image;
    result.error = error;
    
    if (image && !error)
    {
        result.completion = ^(){
        
#ifndef DEBUG
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            [keyWindow makeToast:@"清理临时文件..."];
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:assets];
            } completionHandler:nil];
#endif

        };
    }
    return result;
}
@end

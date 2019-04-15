//
//  SZImagePickerHelper.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SZImageGenerator.h"
#import <Photos/Photos.h>
@protocol SZImagePickerHelperDelegate <NSObject>
- (void)photosRequestAuthorizationFailed;

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion;

- (void)showResult:(SZImageGenerator *)result;

- (void)mergeBegin;

- (void)mergeEnd;
@end

@interface SZImagePickerHelper : NSObject
@property (nonatomic,weak) id<SZImagePickerHelperDelegate>  delegate;
@property (nonatomic, copy) NSArray<UIImage *>* (^chooseImagesComplete)(NSArray<PHAsset *> *images);
@property (nonatomic, copy) void (^alreadySelectImageMaxCount)(void);
- (void)chooseImages;
- (void)clearOriginAssets;
@end

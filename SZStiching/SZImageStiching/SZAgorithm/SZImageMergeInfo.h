//
//  SZImageMergeInfo.h
//  SZStiching
//  提供图片合并的信息
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SZImageFinger.h"
#import "SZConstraint.h"

@interface SZImageMergeInfo : NSObject
@property (nonatomic, strong)    UIImage     *firstImage;
@property (nonatomic, strong)    UIImage     *secondImage;
@property (nonatomic, assign)    NSInteger   firstOffset;    //为计算方便,此处为从 bottom 计算的 offset
@property (nonatomic, assign)    NSInteger   secondOffset;   //为计算方便,此处为从 bottom 计算的 offset
@property (nonatomic, assign)    NSInteger   length;         //重合部分长度
@property (nonatomic, strong) SZImageFinger *finger;//记录secondImage的finger
@property (nonatomic, strong) NSError *error;
- (instancetype)infoBy:(UIImage *)firstImage
           secondImage:(UIImage *)secondImage
                  type:(SZImageFingerType)type;
//校验是否存在有效重叠部分
- (BOOL)validInfo:(SZImageMergeInfo *)info;
#warning 注释
- (void)testPixels:(NSArray *)pixel1 pixel2:(NSArray *)pixel2;
@end

//
//  SZImageFinger.h
//  SZStiching
//  指纹提取类
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SZImageFingerType){
    SZImageFingerTypeCRC, //精准
    SZImageFingerTypeMin,  //模糊
    SZImageFingerType32Min  // 使用32位的像素点
};

@interface SZImageFinger : NSObject
@property (nonatomic, strong) NSMutableArray *lines;//图片提取的指纹数组

+ (instancetype)fingerImage:(UIImage *)image type:(SZImageFingerType)type;
@end

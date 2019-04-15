//
//  SZImageGenerator.h
//  SZStiching
//  图片生成器
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SZImageMergeInfo.h"
#define SZERRORDOMAIN @"www.sz.com"
typedef NS_ENUM(NSInteger, SZMergeError) {
    SZMergeErrorNotSameWidth,     //没有相同的宽度
    SZMergeErrorNotEnoughOverlap,  //没有足够的重叠部分
    SZMergeErrorNotSort        //顺序存在问题
};
@interface SZImageGenerator : NSObject
@property (nonatomic,strong)    NSError *error;
@property (nonatomic, strong) NSMutableArray<SZImageMergeInfo *> *infos;
@property (nonatomic, assign) BOOL stiching;//正在拼接中
- (BOOL)feedImage:(UIImage *)image;
- (BOOL)feedImages:(NSArray *)images;

- (UIImage *)generate;
@end

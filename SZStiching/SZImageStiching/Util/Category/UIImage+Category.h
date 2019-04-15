//
//  UIImage+Category.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/21.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)
/**
 *  获取矩形的渐变色的UIImage(此函数还不够完善)
 *
 *  @param bounds       UIImage的bounds
 *  @param colors       渐变色数组，可以设置两种颜色
 *  @param gradientType 渐变的方式：0--->从上到下   1--->从左到右
 *
 *  @return 渐变色的UIImage
 */

+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors andGradientType:(int)gradientType;

/*
 * 计算图片的大小
 */
- (NSString *)caculateImageSize;
@end

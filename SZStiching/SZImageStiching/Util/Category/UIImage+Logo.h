//
//  UIImage+Logo.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/19.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Logo)
- (UIImage *)addWaterText:(NSString *)text;
// 给图片添加图片水印
- (UIImage *)addWaterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect;
@end

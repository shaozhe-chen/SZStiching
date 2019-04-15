//
//  UIImage+Logo.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/19.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "UIImage+Logo.h"

@implementation UIImage (Logo)

- (UIImage *)addWaterText:(NSString *)text{
    CGPoint point = CGPointMake(self.size.width/2, self.size.height/2);
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:60],NSForegroundColorAttributeName:GLOABLE_COLOR};
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    //2.绘制图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //添加水印文字
    [text drawAtPoint:point withAttributes:dic];

    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

// 给图片添加图片水印
- (UIImage *)addWaterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect{
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    //3.绘制背景图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //绘制水印图片到当前上下文
    [waterImage drawInRect:rect];
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

@end

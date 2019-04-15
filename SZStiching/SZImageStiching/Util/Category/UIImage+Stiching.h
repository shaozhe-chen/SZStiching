//
//  UIImage+Stiching.m
//  Stiching
//
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Stiching)
- (UIImage *)hx_subImage:(CGRect)rect;

- (UIImage *)hx_rangedImage:(NSRange)range;

- (BOOL)hx_saveAsPngFile:(NSString *)path;
@end

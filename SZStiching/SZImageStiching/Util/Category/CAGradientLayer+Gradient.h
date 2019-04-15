//
//  CAGradientLayer+Gradient.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/21.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAGradientLayer (Gradient)
//绘制渐变色颜色的方法
+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view colors:(NSArray<UIColor *> *)colors;
@end

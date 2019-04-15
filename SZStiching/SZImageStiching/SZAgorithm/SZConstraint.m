//
//  SZConstraint.m
//  SZStiching
//  图片约束条件
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZConstraint.h"

@implementation SZConstraint
//- (NSInteger)topOffset
//{
//    if ([UIScreen mainScreen].bounds.size.height == 812)
//    {
//        return (44 + 44) * 3;
//    }
//    else
//    {
//        return (44 + 20) * [[UIScreen mainScreen] scale];
//    }
//    return 20;
//}

//- (NSInteger)bottomOffset
//{
//    if ([UIScreen mainScreen].bounds.size.height == 812)
//    {
//        return (44 + 34) * 3;
//    }
//    else
//    {
//        return (44) * [[UIScreen mainScreen] scale];
//    }
//    return 20;
//}

- (NSInteger)requiredThreshold
{
    return (NSInteger)((self.minImageHeight - self.topOffset - self.bottomOffset) * 0.01);
}
@end

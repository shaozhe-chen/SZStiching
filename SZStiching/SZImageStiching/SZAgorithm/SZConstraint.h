//
//  SZConstraint.h
//  SZStiching
//  图片约束条件
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SZConstraint : NSObject
@property (nonatomic,assign)    CGFloat minImageHeight;
@property (nonatomic, assign) NSInteger topOffset;
@property (nonatomic, assign) NSInteger bottomOffset;
@property (nonatomic, assign) NSInteger requiredThreshold;

- (NSInteger)topOffset;
- (NSInteger)bottomOffset;
- (NSInteger)requiredThreshold;
@end

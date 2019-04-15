//
//  SZStichingImageView.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/31.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 255/5)
@interface SZStichingImageView : UIView
@property (nonatomic, copy) void(^touchBegan)(SZStichingImageView *stichingImageView);
@property (nonatomic, copy) void(^touchEnd)(SZStichingImageView *stichingImageView);
@property (nonatomic, copy) void(^touchMove)(SZStichingImageView *stichingImageView, CGFloat offsetY);
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isEditing) BOOL editing;
@end

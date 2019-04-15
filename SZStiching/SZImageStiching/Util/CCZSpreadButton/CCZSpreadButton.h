//
//  CCZSpreadButton.h
//  CCZSpreadButton
//
//  Created by 金峰 on 2016/11/10.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "CCZSpreadComponentry.h"

@protocol CCZSpreadButtonDelegate;
@interface CCZSpreadButton : CCZSpreadComponentry
@property (nonatomic, weak) id <CCZSpreadButtonDelegate> delegate;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selImage;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, assign) NSUInteger itemsNum;

+ (instancetype)spreadButtonWithCapacity:(NSUInteger)itemsNum;
- (void)spreadButtonDidClickItemAtIndex:(void(^)(NSUInteger index))indexBlock;
@end

@protocol CCZSpreadButtonDelegate <NSObject>
@optional
- (void)spreadButton:(CCZSpreadButton *)spreadButton didSelectedAtIndex:(NSUInteger)index withSelButton:(UIButton *)button;
@end

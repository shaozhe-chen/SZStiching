//
//  CCZSpreadButton.m
//  CCZSpreadButton
//
//  Created by 金峰 on 2016/11/10.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "CCZSpreadButton.h"

typedef void(^spreadHandle)(NSUInteger index);
@interface CCZSpreadButton ()
@property (nonatomic, copy) spreadHandle indexBlock;
@end

@implementation CCZSpreadButton

- (instancetype)initWithCapacity:(NSUInteger)itemsNum {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.subItems = [self itemsArrFromGetItemsNum:itemsNum];
    return self;
}

+ (instancetype)spreadButtonWithCapacity:(NSUInteger)itemsNum {
    return [[self alloc] initWithCapacity:itemsNum];
}

- (NSArray *)itemsArrFromGetItemsNum:(NSUInteger)itemsNum {
    NSMutableArray *itemsArr = [NSMutableArray arrayWithCapacity:itemsNum];
    for (int i = 0; i < itemsNum; i++) {
        UIButton *item = [[UIButton alloc] init];
        item.tag = i;
        [itemsArr addObject:item];
        
        [item addTarget:self action:@selector(didClickButtonAtItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    return [itemsArr copy];
}

- (void)spreadButtonDidClickItemAtIndex:(void (^)(NSUInteger index))indexBlock {
    if (indexBlock) {
        self.indexBlock = indexBlock;
    }
}

#pragma mark -
#pragma mark -- 按钮点击方法

- (void)didClickButtonAtItem:(UIButton *)item {
    ![self.delegate respondsToSelector:@selector(spreadButton:didSelectedAtIndex:withSelButton:)] ?: [self.delegate spreadButton:self didSelectedAtIndex:item.tag withSelButton:item];
    !self.indexBlock ?: self.indexBlock(item.tag);
    [self shrinkWithHandle:NULL];
}

/**
 重写点击方法，解决按钮超出部分无法被电击的问题
 */
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.isSpreading) {
        if (CGRectContainsPoint(self.bounds, point)) {
            return YES;
        }
        for (UIButton *btn in self.subItems) {
            if (CGRectContainsPoint(btn.frame, point)) {
                return YES;
            }
        }
        return NO;
    }else{
        return [super pointInside:point withEvent:event];
    }
}


#pragma mark -
#pragma mark -- set

- (void)setItemsNum:(NSUInteger)itemsNum {
    _itemsNum = itemsNum;
    
    self.subItems = [self itemsArrFromGetItemsNum:itemsNum];
}

- (void)setImages:(NSArray *)images {
    _images = images;
    
    for (int i = 0; i < images.count; i++) {
        UIButton *button = (UIButton *)self.subItems[i];
        button.backgroundColor = GLOABLE_TEXT_COLR;
        [button setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        button.layer.cornerRadius = 22;
        button.clipsToBounds = YES;
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
    }
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = (UIButton *)self.subItems[i];
        NSString *title = titles[i];
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    [self.spreadButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.spreadButton setImage:normalImage forState:UIControlStateNormal];
}

- (void)setSelImage:(UIImage *)selImage {
    _selImage = selImage;
    
    [self.spreadButton setImage:selImage forState:UIControlStateSelected];
}

@end

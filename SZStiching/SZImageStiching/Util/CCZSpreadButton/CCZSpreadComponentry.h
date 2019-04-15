//
//  CCZSpreadComponentry.h
//  CCZSpreadButton
//
//  Created by 金峰 on 2016/11/10.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CCZSpreadStyle) {
    CCZSpreadStylePop,   // 弹出 #Default
    CCZSpreadStyleShape, // 扇形 #未实现
};
@interface CCZSpreadComponentry : UIView
@property (nonatomic, strong) UIButton *spreadButton;
@property (nonatomic, assign) BOOL wannaToScaleSpreadButtonEffect; /**< 开启按钮缩放 #YES*/
@property (nonatomic, assign) CCZSpreadStyle style;
@property (nonatomic, strong) NSArray <UIView *> *subItems;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL spreadButtonOpenViscousity; /**< 开启粘滞功能 #YES*/
@property (nonatomic, assign) CGFloat radius; /**< 弹出btn半径 #22*/
@property (nonatomic, assign) BOOL wannaToClips; /**< 切圆 #YES*/
@property (nonatomic, assign) BOOL canClickTempOn;  /**< 开启背景遮幕 #YES*/
@property (nonatomic, assign) BOOL wannaToClickTempDismiss; /**< 点击屏幕消失 ；需要设置canClickTempOn = YES #YES*/
@property (nonatomic, assign) CGFloat offsetAngle; /**< 偏移角度，默认0。90度方向开始展开*/
@property (nonatomic, assign) BOOL autoAdjustToFitSubItemsPosition; /**< 自动适配subItems的位置 #NO*/
@property (nonatomic, assign) CGFloat spreadDis; /**< 弹开的距离 ；需要设置autoAdjustToFitSubItemsPosition = NO*/
@property (nonatomic, assign) BOOL isSpreading; /**< 是否是展开状态*/
@property (nonatomic, assign) BOOL canMove;

- (instancetype)initWithSubItems:(NSArray <UIView *> *)subItems;
- (void)spreadWithHandle:(void(^)())handle;
- (void)shrinkWithHandle:(void(^)())handle;
- (void)spread  ;
@end

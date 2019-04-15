//
//  AdaptationTool.h
//  AdaptationTool
//
//  Created by chenshaozhe on 2018/9/29.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//建议使用宏
#define TOP_SAFEAREA_HEIGHT [AdaptationTool tool].topSafeArea
#define BOTTOM_SAFEAREA_HEIGHT [AdaptationTool tool].bottomSafeArea
#define NAVIGATIONBAR_HEIGHT [AdaptationTool tool].navigationBarHeight
#define TABBAR_HEIGHT [AdaptationTool tool].tabbarHeight

@interface AdaptationTool : NSObject
/*
 * 如果不是iPhone X等等有有刘海屏的机型，topSafeArea = bottomSafeArea = 0
 * 不要手动修改这写属性。
 */
@property (nonatomic, assign) CGFloat navigationBarHeight;//导航栏的高度
@property (nonatomic, assign) CGFloat topSafeArea;//顶部安全区的高度
@property (nonatomic, assign) CGFloat tabbarHeight;//tabbar的高度
@property (nonatomic, assign) CGFloat bottomSafeArea;//底部安全区的高度

//单例，
+ (instancetype)tool;
//手动计算顶部的安全区域+导航栏的高度
- (void)calculateTopSafeArea;
//手动计算底部的安全区域+tabbar的高度
- (void)calculateBottomSafeArea;
//获取顶部的导航栏
- (UIViewController *)topController;
@end

//
//  AdaptationTool.m
//  AdaptationTool
//
//  Created by chenshaozhe on 2018/9/29.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "AdaptationTool.h"

@implementation AdaptationTool
+ (instancetype)tool{
    static dispatch_once_t onceToken;
    static AdaptationTool *tool = nil;
    dispatch_once(&onceToken, ^{
        tool = [AdaptationTool new];
        [tool calculateTopSafeArea];
        [tool calculateBottomSafeArea];
    });
    return tool;
}

- (void)calculateTopSafeArea{
    UINavigationController *navi = [self topController].navigationController;
#if DEBUG
    NSAssert(navi != nil, @"您没有导航控制器");
#endif
    if (navi == nil) {
        NSLog(@"您没有导航控制器");
        return;
    }
    UINavigationBar *bar = navi.navigationBar;
    CGFloat navigationBarHeight = [self enumerationBarSubview:bar];
    self.navigationBarHeight = navigationBarHeight;
    self.topSafeArea = self.navigationBarHeight - 44;
}

//计算
- (void)calculateBottomSafeArea{
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
#if DEBUG
    NSAssert(vc != nil, @"您没有为window设置rootViewController");
//    NSAssert(([vc isKindOfClass:[UITabBarController class]]&&vc!=nil), @"您的rootViewController不是UITabBarController类型");
#endif
    if (vc == nil) {
        NSLog(@"您没有为window设置rootViewController");
        return;
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarVC = (UITabBarController *)vc;
        CGFloat tabbarHeight = [self enumerationBarSubview:tabbarVC.tabBar];
        self.tabbarHeight = tabbarHeight;
        self.bottomSafeArea = self.tabbarHeight - 49;
    }
    else{
        NSLog(@"rootViewController 不是 UITabBarController.class，请检查您的window.rootViewController是否s是UITabBarController。如有其它需求，请自行修改代码即可");
    }
}

#pragma mark 获取_UIBarBackground类的对象的高度 和 top安全区的高度
- (CGFloat)enumerationBarSubview:(UIView *)bar{
    for (UIView *view in bar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            return view.frame.size.height;
        }
        else{
            return [self enumerationBarSubview:view];
        }
    }
    //如果是导航栏UINavigationBar
    if ([bar isKindOfClass:[UINavigationBar class]]) {
        return 64;
    }
    //如果是Tabbar
    else{
        return 49;
    }
}

#pragma mark 获取顶部的控制器
- (UIViewController *)topController{
    UIViewController *topVC = [self getTopViewController:[[UIApplication sharedApplication].delegate.window rootViewController]];
    //如果是模态控制器
    while (topVC.presentedViewController) {
        topVC = [self getTopViewController:topVC.presentedViewController];
    }
    return topVC;
}

- (UIViewController *)getTopViewController:(UIViewController *)controller{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self getTopViewController:[(UINavigationController *)controller topViewController]];
    }
    else if ([controller isKindOfClass:[UITabBarController class]]){
        return [self getTopViewController:[(UITabBarController *)controller selectedViewController]];
    }
    else{
        return controller;
    }
}
@end

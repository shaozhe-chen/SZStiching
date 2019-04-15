//
//  SZImagePreVewController.h
//  合成图片预览控制器
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZImageGenerator.h"

@interface SZImagePreVewController : UIViewController
@property (nonatomic,copy)  dispatch_block_t completion;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithGenerator:(SZImageGenerator *)generator;
@end

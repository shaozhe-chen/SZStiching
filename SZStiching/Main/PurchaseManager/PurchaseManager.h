//
//  PurchaseManager.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseManager : NSObject
+ (instancetype)createPurchaseManager;
- (void)requestProductId:(NSString *)productId ;
@end

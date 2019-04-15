//
//  SZPurchaseListModel.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, PurchaseType) {
    PurchaseNoneType,       //默认4张图片
    PurchaseSixYuanType,   //6元解锁8张图片
    PurchaseTwelveType     //12元解锁15张图片
};

@interface SZPurchaseListModel : NSObject
@property (nonatomic, copy) NSString *purName;
@property (nonatomic, assign) PurchaseType purchaseType;
@property (nonatomic, assign) BOOL hasPurchase;
@end

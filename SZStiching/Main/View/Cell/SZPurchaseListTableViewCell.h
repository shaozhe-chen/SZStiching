//
//  SZPurchaseListTableViewCell.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZPurchaseListModel.h"
@interface SZPurchaseListTableViewCell : UITableViewCell
- (void)updateCellWith:(SZPurchaseListModel *)model;
@end

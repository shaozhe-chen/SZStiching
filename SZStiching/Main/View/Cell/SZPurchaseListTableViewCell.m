//
//  SZPurchaseListTableViewCell.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZPurchaseListTableViewCell.h"

@interface SZPurchaseListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *purchaseNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@end


@implementation SZPurchaseListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = GLOABLE_SELECT_COLOR;
}


- (void)updateCellWith:(SZPurchaseListModel *)model {
    self.purchaseNameLabel.text = model.purName;
    [self.purchaseNameLabel sizeToFit];
    if (model.hasPurchase) {
        self.lockImageView.hidden = YES;
        [self.purchaseNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-7);
        }];
    }else {
        self.lockImageView.hidden = NO;
        [self.purchaseNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.lockImageView.mas_left).offset(10);
        }];
    }
}

@end

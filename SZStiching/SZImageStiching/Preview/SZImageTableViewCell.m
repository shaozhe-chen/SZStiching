//
//  SZImageTableViewCell.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/21.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZImageTableViewCell.h"

@interface SZImageTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *aImageView;
@end


@implementation SZImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.aImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)updateImage:(UIImage *)image {
    self.aImageView.image = image;
    //[UIScreen mainScreen].scale
    CGFloat imageH = image.size.height/(image.size.width/SCREEN_WIDTH);
    [self.aImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(imageH));
    }];
}

@end

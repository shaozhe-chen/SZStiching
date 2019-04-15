//
//  SZEditorView.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/13.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZEditorView.h"
#import <UIView+YYAdd.h>

@interface SZEditorView ()
@property (nonatomic, strong) UIImageView *aniDown;
@property (nonatomic, strong) UIImageView *aniUp;
@end


@implementation SZEditorView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = GLOABLE_COLOR;
        [self configViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _editorIcon.center = CGPointMake((self.width)/2, 2.5);
}

- (void)configViews {
    _editorIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    _editorIcon.size = CGSizeMake(EDITORVIEW_SIZE, EDITORVIEW_SIZE);
    [_editorIcon setImage:[UIImage imageNamed:@"stiching_edit"] forState:UIControlStateNormal];
    [_editorIcon addTarget:self action:@selector(beganEditor:) forControlEvents:UIControlEventTouchUpInside];
    _editorIcon.userInteractionEnabled = YES;
    _editorIcon.backgroundColor = GLOABLE_COLOR;
    _editorIcon.layer.cornerRadius = EDITORVIEW_SIZE/2;
    _editorIcon.clipsToBounds = YES;
    NSInteger space = 8;
    [_editorIcon setImageEdgeInsets:UIEdgeInsetsMake(space, space, space, space)];
//    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beganEditor:)];
//    [_editorIcon addGestureRecognizer:gesture];
    [self addSubview:_editorIcon];
}

- (void)beganEditor:(UIButton *)btn {
    NSLog(@"你点到我了。。");
    btn.selected = !btn.isSelected;
    if (self.touchBegan) {
        self.touchBegan(self);
    }
    self.editing = btn.isSelected;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchBegan) {
        self.touchBegan(self);
    }
//    self.hidden = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.hidden = NO;
}


- (void)setEditing:(BOOL)editing {
    _editing = editing;
    self.firstImageView.editing = editing;
    self.lastImageView.editing = editing;
}

@end

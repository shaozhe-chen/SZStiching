//
//  SZEditorView.h
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/13.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZStichingImageView.h"
@interface SZEditorView : UIView
@property (nonatomic, strong) UIButton *editorIcon;
@property (nonatomic, strong) SZStichingImageView *firstImageView;
@property (nonatomic, strong) SZStichingImageView *lastImageView;
@property (nonatomic, assign, getter=isEditing) BOOL editing;
@property (nonatomic, copy) void(^touchBegan)(SZEditorView *editorView);
@end

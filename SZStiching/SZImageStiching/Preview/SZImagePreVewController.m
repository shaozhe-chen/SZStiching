//
//  SZImagePreVewController.m
//  合成图片之后预览
//
//  Created by amao on 11/27/15.
//  Copyright © 2015 M80. All rights reserved.
//

#import "SZImagePreVewController.h"
#import "UIView+Toast.h"
#import "UIImage+Logo.h"
#import "SZStichingImageView.h"
#import <YYKit/UIView+YYAdd.h>
#import "SZEditorView.h"
#import "SZScrollView.h"
#import <YYKit/YYKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define MIN_HEIGHT 50
#define EDITOR_BAR_HEIGHT 5

@interface SZImagePreVewController ()<
ZWMGuideViewDataSource,
ZWMGuideViewLayoutDelegate
>
@property (nonatomic,strong)  SZScrollView    *scrollView;
@property (nonatomic,strong)  UIImage         *image;
@property (nonatomic,assign)  CGFloat          totoalHeight;
@property (nonatomic, strong) SZImageGenerator *generator;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *editViews;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (strong, nonatomic) ZWMGuideView *guideView;

@property (nonatomic, strong) NSMutableArray *guideViews;
@property (nonatomic, strong) NSMutableArray *guideDesc;
@property (nonatomic, assign) BOOL scrollEnable;
@end

@implementation SZImagePreVewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _image = image;
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, image.size.height * (SCREEN_WIDTH/image.size.width));
    }
    return self;
}

- (instancetype)initWithGenerator:(SZImageGenerator *)generator{
    if (self = [super init]) {
        _generator = generator;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *layer = [CAGradientLayer setGradualChangingColor:self.view colors:@[RGB(33, 46, 66),RGB_A(59, 75, 110, 0.8)]];
    [self.view.layer addSublayer:layer];
    
    NSString *guide_show_key = [[NSUserDefaults standardUserDefaults] valueForKey:GUIDE_PRE_SHOW_KEY];
    if (guide_show_key == nil) {
        _guideViews = [NSMutableArray array];
        _guideDesc = [NSMutableArray array];
    }
    _scrollView = [[SZScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    _scrollView.contentSize = self.view.bounds.size;
    [self.view addSubview:_scrollView];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SZLocalizedString(@"取消")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onDismiss:)];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:SZLocalizedString(@"保存") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
    [btn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *cancelbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelbtn setTitle:SZLocalizedString(@"结束编辑") forState:UIControlStateNormal];
    [cancelbtn addTarget:self action:@selector(hxEndEditing) forControlEvents:UIControlEventTouchUpInside];
    [cancelbtn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
    [cancelbtn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
    cancelbtn.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelbtn];
    self.navigationItem.rightBarButtonItems = @[rightItem, cancelItem];
    self.title = SZLocalizedString(@"图片编辑");
    
    [self.guideViews addObject:btn];
    
    if (_imageView) {
        [self.scrollView addSubview:_imageView];
        self.scrollView.contentSize = _imageView.size;
        return;
    }
    
    [self configImageViews];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *guide_show_key = [[NSUserDefaults standardUserDefaults] valueForKey:GUIDE_PRE_SHOW_KEY];
        if (guide_show_key == nil) {
            [self configGuideViews];
            [[NSUserDefaults standardUserDefaults] setValue:GUIDE_PRE_SHOW_KEY forKey:GUIDE_PRE_SHOW_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    });
}

- (void)configGuideViews {
    
    NSArray *descs = @[
                       SZLocalizedString(@"图片已经自动识别并拼接好啦，点击‘保存’就可以保存到相册啦"),
                       SZLocalizedString(@"点击编辑按钮，编辑按钮上下两张图片可以上下拖动调整位置哦")
                       ];
    _guideDesc = [NSMutableArray arrayWithArray:descs];
    [self.guideView show];
    
}

- (void)configImageViews{
    if (!_generator.infos.count) {
        return;
    }
    [self.editViews removeAllObjects];
    self.scrollEnable = YES;
    __block NSInteger editTouchIndex = 0;
    @WeakObj(self);
    for (NSInteger i = 0; i <= _generator.infos.count + 1; i ++) {
        SZEditorView *editorView = [SZEditorView new];
        editorView.touchBegan = ^(SZEditorView *editorView) {
            @StrongObj(self);
            self.scrollEnable = !editorView.editorIcon.isSelected;
            self.scrollView.scrollEnabled = self.scrollEnable;
            for (SZEditorView *editor in self.editViews) {
                editor.editing = NO;
            }
            editorView.editing = YES;
            editTouchIndex = i;
        };
        [self.editViews addObject:editorView];
    }
    
    [self.guideViews addObject:self.editViews[1]];
    //用于触发按钮事件
    self.scrollView.editors = self.editViews;
    @weakify(self);
    SZImageMergeInfo *firstInfo = _generator.infos.firstObject;
    CGFloat firstImagescale = SCREEN_WIDTH / firstInfo.firstImage.size.width;
    SZStichingImageView *lastImageView = [[SZStichingImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, firstInfo.firstImage.size.height * firstImagescale)];
    lastImageView.image = firstInfo.firstImage;
    lastImageView.touchMove = ^(SZStichingImageView *stichingImageView, CGFloat offsetY) {
        @strongify(self)
        //第一张图片，存在两种操作：点击的是最顶比的编辑条。点击的是第二条编辑条
        if (editTouchIndex == 0) {
           [self firstImageScrollUp:stichingImageView offsetY:offsetY];
        }else if(editTouchIndex == 1) {
            [self topImageScrollDown:stichingImageView offsetY:offsetY];
        }
    };
    
    lastImageView.touchEnd = ^(SZStichingImageView *stichingImageView) {
        @strongify(self);
        if (editTouchIndex == 0) {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                stichingImageView.height = stichingImageView.height - stichingImageView.imageView.top;
                stichingImageView.imageView.top = 0;
                [self bottomFollow:stichingImageView  isFirstImage:YES];
                [self updateEditorBarPosition];
                [self updateScrollViewContentSize];
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
            }];
        }else if(editTouchIndex == 1) {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                stichingImageView.imageView.top = 0;
                stichingImageView.top = 0;
                [self bottomFollow:stichingImageView isFirstImage:YES];
                [self updateEditorBarPosition];
                [self updateScrollViewContentSize];
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
            }];
        }
    };
    
    //第一个编辑条
    SZEditorView *firstEditorView = self.editViews.firstObject;
    firstEditorView.firstImageView = nil;
    firstEditorView.lastImageView = lastImageView;
    firstEditorView.top = lastImageView.top ;
    firstEditorView.left = 0;
    firstEditorView.width = lastImageView.width;
    firstEditorView.height = EDITOR_BAR_HEIGHT;
    
    
    [self.scrollView addSubview:lastImageView];
    [self.scrollView addSubview:firstEditorView];
    [self.imageViews addObject:lastImageView];
    
    NSInteger index = 0;
    for (SZImageMergeInfo *info in _generator.infos) {
        CGFloat scale = SCREEN_WIDTH / info.secondImage.size.width;
        CGFloat secondImageH = info.secondImage.size.height * scale;
        SZStichingImageView *imageView = [[SZStichingImageView alloc] initWithFrame:CGRectMake(0, lastImageView.bottom, SCREEN_WIDTH, secondImageH)];
        imageView.image = info.secondImage;
         [self.scrollView addSubview:imageView];
        if (!info.error) {
            lastImageView.height = lastImageView.height - (info.firstOffset) * scale;
            imageView.top = lastImageView.bottom;
            imageView.height = (info.secondOffset) * scale;
            imageView.imageView.top = - secondImageH + (info.secondOffset) * scale;
        }
        SZEditorView *ediView = self.editViews[index + 1];
        ediView.firstImageView = [self.imageViews lastObject];
        ediView.lastImageView = imageView;
        ediView.left = 0;
        ediView.width = imageView.width;
        ediView.height = EDITOR_BAR_HEIGHT;
        ediView.bottom = lastImageView.bottom;
        [self.scrollView addSubview:ediView];
       
        
        lastImageView = imageView;
        [self.imageViews addObject:imageView];

        @weakify(self);
        imageView.touchEnd = ^(SZStichingImageView *stichingImageView) {
            @strongify(self);
            BOOL isLastIndex = editTouchIndex == self.editViews.count - 1;
            SZEditorView *editorView = self.editViews[editTouchIndex];
            editorView.hidden = NO;
            //为了避免边滚动，边更新self.scrollView.contentSize导致的动画不正常
            if (isLastIndex) {
//                [UIView animateWithDuration:0.5 animations:^{
                    [self updateScrollViewContentSize];
                    //最后的编辑条，总是要在scrollView更新contentSize之后
                    SZEditorView *lastEditorView = [self.editViews lastObject];
                    lastEditorView.bottom = self.scrollView.contentSize.height;
//                }];
            } else {
                [self updateScrollViewContentSize];
                //最后的编辑条，总是要在scrollView更新contentSize之后
                SZEditorView *lastEditorView = [self.editViews lastObject];
                lastEditorView.bottom = self.scrollView.contentSize.height;
                NSLog(@"更新：%@",@(self.scrollView.contentSize.height));
            }
        };
        
        imageView.touchMove = ^(SZStichingImageView *stichingImageView, CGFloat offsetY) {
            @strongify(self);
            NSInteger canMoveIndex = [self.imageViews indexOfObject:stichingImageView];
            BOOL isAbove = canMoveIndex >= editTouchIndex;
            BOOL isLastIndex = editTouchIndex == self.editViews.count - 1;
            SZEditorView *editorView = self.editViews[editTouchIndex];
            editorView.hidden = YES;
            //获取点击的可编辑的editview
             SZEditorView *ediView_ = self.editViews[editTouchIndex];
            //滚动可编辑的上面一张图片
            if (ediView_.firstImageView == stichingImageView && !isLastIndex) {
                [self topImageScrollDown:stichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //滚动可编辑的下面的一张图片
            else if (ediView_.lastImageView == stichingImageView  && !isLastIndex) {
                [self belowImageScrollUp:stichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //滚动可编辑的图片之上的所有图片
            else if (isAbove && !isLastIndex) {
                SZStichingImageView *aboveStichingImageView = ediView_.lastImageView;
                [self belowImageScrollUp:aboveStichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            //滚动可编辑的图片之下的所有图片
            else if (!isAbove && !isLastIndex) {
                  SZStichingImageView *underStichingImageView = ediView_.firstImageView;
                 [self topImageScrollDown:underStichingImageView offsetY:offsetY];
                
                [self updateEditorBarPosition];
            }
            else if (isLastIndex) {
                [self belowImageScrollUp:stichingImageView offsetY:offsetY];
            }
 
        };
        index ++;
    }
    _totoalHeight = lastImageView.bottom;
    for (UIView *childView in self.scrollView.subviews.reverseObjectEnumerator) {
        [self.scrollView bringSubviewToFront:childView];
    }
    for (SZEditorView *editorView in self.editViews) {
        [self.scrollView bringSubviewToFront:editorView];
    }
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _totoalHeight);
    
    //最后一个编辑条
    SZEditorView *lastEditorView = self.editViews.lastObject;
    lastEditorView.firstImageView = nil;
    lastEditorView.lastImageView = lastImageView;
    lastEditorView.left = 0;
    lastEditorView.width = lastImageView.width;
    lastEditorView.height = EDITOR_BAR_HEIGHT;
    lastEditorView.bottom = self.scrollView.contentSize.height;
    [self.scrollView addSubview:lastEditorView];
}

/*
 * 滚动可编辑上面的图片
 */
- (void)topImageScrollDown:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.height = stichingImageView.height - offsetY;
    if ((stichingImageView.height >= stichingImageView.imageView.bottom) ||
        (stichingImageView.height <= MIN_HEIGHT)) {
        stichingImageView.height = stichingImageView.imageView.bottom;
        return;
    }
    stichingImageView.top = stichingImageView.top + offsetY;
    
    //顶部跟随
    [self topFollow:stichingImageView offsetY:offsetY isLastImage:NO];
}

/*
 * 滚动可编辑下面的图片
 */
- (void)belowImageScrollUp:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.height = stichingImageView.height + offsetY;
    stichingImageView.imageView.top = stichingImageView.imageView.top  + offsetY;
    if (stichingImageView.imageView.top >= 0.0 || (stichingImageView.height <= MIN_HEIGHT)) {
        stichingImageView.height = stichingImageView.height - offsetY;
        stichingImageView.imageView.top = stichingImageView.imageView.top - offsetY;
        return;
    }
   
    //底部跟随
    [self bottomFollow:stichingImageView isFirstImage:NO];
}

/*
 * 滚动第一张图片
 */
- (void)firstImageScrollUp:(SZStichingImageView *)stichingImageView offsetY:(CGFloat)offsetY {
    stichingImageView.imageView.top = stichingImageView.imageView.top  + offsetY;
    if ((stichingImageView.height <= MIN_HEIGHT) ||
        stichingImageView.height >= stichingImageView.imageView.bottom) {
        stichingImageView.imageView.top = stichingImageView.imageView.top - offsetY;
        stichingImageView.top = 0;
        return;
    }
   
}

/*
 * 底部跟随
 * stichingImageView 需要跟随谁的底部
 * isFirstImage 是否是第一张图片，如果是的画，底部所有的图片都会跟随
 */
- (void)bottomFollow:(SZStichingImageView *)stichingImageView isFirstImage:(BOOL) isFirstImage{
    SZStichingImageView *lastStichimageView = stichingImageView;
    NSInteger inlineIndex = [self.imageViews indexOfObject:stichingImageView];
    if ((inlineIndex + 1) < self.imageViews.count) {
        for (NSInteger i = inlineIndex + 1; i < self.imageViews.count; i ++) {
            SZStichingImageView *imageView = self.imageViews[i];
            if (i == (inlineIndex + 1) && !isFirstImage) {
                if (imageView.isEditing) {
                    break;
                }
            }
            imageView.top = lastStichimageView.bottom;
            lastStichimageView = imageView;
        }
    }
}

/*
 * 顶部跟随
 * stichingImageView 需要跟随谁的顶部
 */
- (void)topFollow:(SZStichingImageView *)stichingImageView offsetY:(CGFloat) offsetY isLastImage:(BOOL) isLastImage{
    SZStichingImageView *lastStichimageView = stichingImageView;
    NSInteger inlineIndex = [self.imageViews indexOfObject:stichingImageView];
    if ((inlineIndex - 1) >= 0) {
        for (NSInteger i =  inlineIndex - 1 ; i >= 0; i --) {
            SZStichingImageView *imageView = self.imageViews[i];
            if (i == (inlineIndex - 1) && !isLastImage) {
                if (imageView.isEditing) {
                    break;
                }
            }
            imageView.top = imageView.top + offsetY;
            lastStichimageView = imageView;
        }
    }
}

/*
 * 更新可编辑条的位置
 */
- (void)updateEditorBarPosition {
    NSInteger i = 0;
    SZEditorView *firstEditorView = [self.editViews firstObject];
    firstEditorView.top = 0;
    
    for (SZStichingImageView *imageView in self.imageViews) {
        if (i + 1 >= self.imageViews.count) {
            break;
        }
        SZEditorView *editorView = self.editViews[i + 1];
        editorView.bottom = imageView.bottom;
        i ++;
    }
    
//    [self updateScrollViewContentSize];
//    SZStichingImageView *bottomView = self.imageViews.lastObject;
//    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, bottomView.bottom);
//
//    //最后的编辑条，总是要在scrollView更新contentSize之后
//    SZEditorView *lastEditorView = [self.editViews lastObject];
//    lastEditorView.bottom = self.scrollView.contentSize.height;
//    NSLog(@"更新：%@",@(self.scrollView.contentSize.height));
}

- (void)updateScrollViewContentSize {
    CGFloat totalHeight = 0;
    for (SZStichingImageView *imageView in self.imageViews) {
        totalHeight += imageView.height;
    }
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    SZStichingImageView *lastImageView = self.imageViews.lastObject;
//    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, lastImageView.bottom);
}

#pragma mark -- ZWMGuideViewDataSource（必须实现的数据源方法）
- (NSInteger)numberOfItemsInGuideMaskView:(ZWMGuideView *)guideMaskView{
    return self.guideViews.count;
    
}
- (UIView *)guideMaskView:(ZWMGuideView *)guideMaskView viewForItemAtIndex:(NSInteger)index{
    return self.guideViews[index];
    
}
- (NSString *)guideMaskView:(ZWMGuideView *)guideMaskView descriptionLabelForItemAtIndex:(NSInteger)index{
    return self.guideDesc[index];
}

#pragma mark -- ZWMGuideViewLayoutDelegate
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView cornerRadiusForItemAtIndex:(NSInteger)index
{
    if (index == self.guideViews.count-1)
    {
        return 30;
    }
    
    return 5;
}

- (UIEdgeInsets)guideMaskView:(ZWMGuideView *)guideMaskView insetsForItemAtIndex:(NSInteger)index{
    return UIEdgeInsetsMake(-20, -10, -20, -10);
}



- (void)onDismiss:(id)sender
{
    [self dismiss];
}

- (void)onSave:(id)sender
{
    _image = [self stichingResultImage];
   _image = [_image addWaterText:SZLocalizedString(@"图拼拼")];
   _image = [_image addWaterImage:[UIImage imageNamed:@"logo"] waterImageRect:CGRectMake(_image.size.width/2, 20, 300, 300)];
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)hxEndEditing {
    self.scrollView.scrollEnabled = YES;
    self.scrollEnable = YES;
    for (SZEditorView *edtorView in self.editViews) {
        edtorView.editing = NO;
    }
}

- (UIImage *)stichingResultImage {
    SZStichingImageView *lastImageView = self.imageViews.lastObject;
    SZStichingImageView *firstImageView = self.imageViews.firstObject;
    CGFloat scale = lastImageView.image.size.width / SCREEN_WIDTH;
    CGFloat offsetY = 0;
    NSLog(@"准备使用：%@",@(self.scrollView.contentSize.height));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, lastImageView.bottom + fabs(firstImageView.top)), NO, [UIScreen mainScreen].scale);
    @autoreleasepool {
        for (SZStichingImageView *imageView in self.imageViews) {
            @autoreleasepool {
                UIImage *image = imageView.image;
                CGImageRef imageCropRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, fabs(imageView.imageView.top * scale), image.size.width * scale, (imageView.height * scale)));
                UIImage *imageCrop = [UIImage imageWithCGImage:imageCropRef scale:image.scale orientation:UIImageOrientationUp];
                CGFloat realHeight = imageCrop.size.height/imageCrop.size.width * SCREEN_WIDTH ;
                [imageCrop drawInRect:CGRectMake(0, offsetY, imageCrop.size.width/scale, realHeight)];
                offsetY += realHeight;
                CGImageRelease(imageCropRef);
            }
        }
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"图片高度：%@",@(resultImage.size.height));
    return resultImage;
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *) error
  contextInfo:(void *) contextInfo
{
    if (error)
    {
        [self.view makeToast:SZLocalizedString(@"保存图片失败")];
    }
    else
    {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow makeToast:SZLocalizedString(@"保存图片成功")];
        [self dismiss];
    }
}

- (NSMutableArray *)editViews {
    if (!_editViews) {
        _editViews = [NSMutableArray array];
    }
    return _editViews;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (ZWMGuideView *)guideView
{
    if (_guideView == nil) {
        _guideView = [[ZWMGuideView alloc] initWithFrame:self.navigationController.view.bounds];
        _guideView.dataSource = self;
        _guideView.delegate = self;
    }
    return _guideView;
}

- (void)dismiss
{
    dispatch_block_t completion = self.completion;
    [self dismissViewControllerAnimated:YES
                             completion:completion];
}
@end



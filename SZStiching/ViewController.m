//
//  ViewController.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "SZImagePreVewController.h"
#import "UIView+Toast.h"
#import "SZImagePickerHelper.h"
#import "SZImageGenerator.h"
#import "SZImageMergeInfo.h"
#import "SZImageTableViewCell.h"
#import "UIImage+Logo.h"
#import <Photos/Photos.h>
#import "UIImage+Category.h"
#import "CCZSpreadButton.h"
#import "SZPurchaseListViewController.h"
@interface ViewController ()<
    SZImagePickerHelperDelegate,
    UIAlertViewDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    ZWMGuideViewDataSource,
    ZWMGuideViewLayoutDelegate
>
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (nonatomic, strong) SZImagePickerHelper *helper;
@property (weak, nonatomic) IBOutlet UIButton *startStichingBtn;
@property (nonatomic, strong) SZImageMergeInfo *info;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) SZImageGenerator *generator;
@property (nonatomic, assign) BOOL needJumpToPreviewController;//如果识别还未结束，就点了拼接，需要展示loading，并在loading结束的时候跳去PreviewController
@property (nonatomic, strong) CCZSpreadButton *com;
@property (strong, nonatomic) ZWMGuideView *guideView;

@property (nonatomic, strong) NSMutableArray *guideViews;
@property (nonatomic, strong) NSMutableArray *guideDesc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHelper];
    _info = [SZImageMergeInfo new];
    _dataSource = [NSMutableArray array];
    _startStichingBtn.hidden = YES;
    
    NSString *guide_show_key = [[NSUserDefaults standardUserDefaults] valueForKey:GUIDE_SHOW_KEY];
    if (guide_show_key == nil) {
        _guideViews = [NSMutableArray array];
        _guideDesc = [NSMutableArray array];
    }
    
    CAGradientLayer *layer = [CAGradientLayer setGradualChangingColor:self.view colors:@[RGB(33, 46, 66),RGB_A(59, 75, 110, 0.8)]];
    [self.view.layer addSublayer:layer];
    
    self.tipLabel1.text = SZLocalizedString(@"确保图片有10%左右的重叠部分");
    [self.view bringSubviewToFront:self.tipLabel1];
    self.tipLabel2.text = SZLocalizedString(@"自动拼接如果存在误差，可以手动调整哦");
    [self.view bringSubviewToFront:self.tipLabel2];
    
    [self.view addSubview:self.tableView];
    
    [self.view bringSubviewToFront:self.startStichingBtn];

    [self configNavigationBar];
    
    [self configSpreadButton];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = SZLocalizedString(@"长图拼接");
    _startStichingBtn.layer.cornerRadius = 40;
    _startStichingBtn.clipsToBounds = YES;
    _startStichingBtn.backgroundColor = RGB_A(33, 46, 66, 0.5);
    [_startStichingBtn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
    [_startStichingBtn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *guide_show_key = [[NSUserDefaults standardUserDefaults] valueForKey:GUIDE_SHOW_KEY];
        if (guide_show_key == nil) {
            [self configGuideViews];
            [[NSUserDefaults standardUserDefaults] setValue:GUIDE_SHOW_KEY forKey:GUIDE_SHOW_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
     
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    @autoreleasepool {
        self.generator = nil;
    }
}

- (void)configGuideViews {
 
    NSArray *descs = @[
                       SZLocalizedString(@"这里藏了其它功能哟！"),
                       SZLocalizedString(@"点击可以选择图片，开始拼图！"),
                       SZLocalizedString(@"选择完图片之后，点击“自动拼接”，可实现长图自动拼接哦！"),
                       SZLocalizedString(@"简单拼接，不去掉重复部分，简单的把图片的尾部和头部直接拼接成长图，然后保存到相册！"),
                       SZLocalizedString(@"如果选择的图片不需要了，可以点击该按钮，清空已选择的图片！")
                      ];
     _guideDesc = [NSMutableArray arrayWithArray:descs];
    self.guideView.height = SCREEN_HEIGHT;
    [self.guideView show];
    
    //第一次默认展开
    [self.com spread];
    
}

- (void)configSpreadButton {
    CCZSpreadButton *com  = [[CCZSpreadButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    com.itemsNum = 3;
    com.spreadButtonOpenViscousity = NO;
    com.backgroundColor = GLOABLE_TEXT_COLR;
    com.layer.cornerRadius = 30;
    com.autoAdjustToFitSubItemsPosition = NO;
    com.spreadDis = SCALE_VALUE(100);
    [self.view addSubview:com];
    self.com = com;
    com.normalImage = [UIImage imageNamed:@"stiching_more"];
    com.selImage = [UIImage imageNamed:@"stiching_more"];
    com.images = @[@"stiching_save",@"choose_pic",@"empty_img"];
//    com.titles = @[@"保存", @"选择图片", @"清空图片", @"自动拼接"];
    @WeakObj(self);
    [com spreadButtonDidClickItemAtIndex:^(NSUInteger index) {
        @StrongObj(self);
        //保存图片
        if (index == 0) {
            [self saveImage];
        }else if (index == 1) {
            [self chooseImage];
        }else if (index == 2) {
            [self clearImages];
        }
    }];
    
    [com mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-SCALE_VALUE(30)));
        make.bottom.equalTo(@(-SCALE_VALUE(30+34)));
        make.width.height.equalTo(@(60));
    }];
    
    [self.guideViews addObject:self.com];
    [self.guideViews exchangeObjectAtIndex:0 withObjectAtIndex:1];
    [self.guideViews insertObject:self.com.subItems[1] atIndex:1];
    [self.guideViews addObject:self.com.subItems.firstObject];
    [self.guideViews addObject:self.com.subItems.lastObject];
}

/*
 * 配置拼接图片帮助中心
 */
- (void)configHelper {
    _helper = [[SZImagePickerHelper alloc] init];
    _helper.delegate = self;
    [_dataSource removeAllObjects];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    @WeakObj(self);
    _helper.chooseImagesComplete = ^NSArray<UIImage *> *(NSArray *images) {
        @StrongObj(self);
        //每次选择结束都需要清除以前的图片
        [self.dataSource removeAllObjects];
        [self.generator.infos removeAllObjects];
        self.generator.stiching = YES;
            for (PHAsset *asset in images)
            {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                  options:options
                                                            resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                                if (imageData) {
                                                                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                    [self.dataSource addObject:image];
                                                                }
                                                            }];
            }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return self.dataSource;
    };
    
    //选择图片达到最大图片数
    _helper.alreadySelectImageMaxCount = ^{
        [SVProgressHUD showErrorWithStatus:SZLocalizedString(@"解锁无限制版，可以让您体验最大10张图的拼接效果哦")];
    };
}

- (void)configNavigationBar {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:SZLocalizedString(@"自动拼接") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startMergeImage:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
    [btn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.guideViews addObject:btn];

    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [lockBtn setTitle:@"清空图片" forState:UIControlStateNormal];
    [lockBtn setImage:LoadImage(@"lock") forState:UIControlStateNormal];
    [lockBtn addTarget:self action:@selector(jumpToUnlookController) forControlEvents:UIControlEventTouchUpInside];
    [lockBtn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
    lockBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [lockBtn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
    UIBarButtonItem *lockItem = [[UIBarButtonItem alloc] initWithCustomView:lockBtn];
    self.navigationItem.leftBarButtonItem = lockItem;
//
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setTitle:@"保存" forState:UIControlStateNormal];
//    [leftBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    [leftBtn setTitleColor:GLOABLE_TEXT_COLR forState:UIControlStateNormal];
//    leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [leftBtn setTitleColor:GLOABLE_TEXT_SELECT_COLOR forState:UIControlStateHighlighted];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
//    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void) jumpToUnlookController {
    SZPurchaseListViewController *vc = [SZPurchaseListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
 * 选择图片
 */
- (void)chooseImage {
    [_helper chooseImages];
}

- (void)clearImages {
    [self.dataSource removeAllObjects];
    [self.generator.infos removeAllObjects];
    [_helper clearOriginAssets];
    [self.tableView reloadData];
}

/*
 * 不自动识别，直接保存图片
 */
- (void)saveImage {
    if (self.dataSource.count == 0) {
        return;
    }
    
    if (self.dataSource.count == 1) {
        [self.view makeToast:SZLocalizedString(@"您只有一张图片，无法拼接，不需要保存")];
        return;
    }
    
    if (self.dataSource.count < 2 && self.dataSource.count != 0) {
        [self.view makeToast:SZLocalizedString(@"拼接图片需要2张以上的图片哟")];
        return;
    }
    
   
    UIImage *resultImage = [self stichingResultImage];
    resultImage = [resultImage addWaterText:@"陈少哲出品"];
    resultImage = [resultImage addWaterImage:[UIImage imageNamed:@"logo"] waterImageRect:CGRectMake(resultImage.size.width/2, resultImage.size.height - 300 , SCREEN_WIDTH, 300)];
    NSString *imageSize = [resultImage caculateImageSize];
    NSString *title = [NSString stringWithFormat:@"%@",imageSize];
     [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在保存图片，图片大小：%@M",title]];
    UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
   
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error  contextInfo:(void *) contextInfo
{
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:SZLocalizedString(@"保存图片失败")];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:SZLocalizedString(@"保存图片失败")];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

/*
 * 拼接图片，生成image
 */
- (UIImage *)stichingResultImage {
    CGFloat offsetY = 0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, self.tableView.contentSize.height), NO, [UIScreen mainScreen].scale);
    @autoreleasepool {
        for (UIImage *image in self.dataSource) {
            @autoreleasepool {
            CGFloat scale = image.size.width/SCREEN_WIDTH;
            CGImageRef imageCropRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, image.size.width, image.size.height * scale));
            UIImage *imageCrop = [UIImage imageWithCGImage:imageCropRef scale:image.scale orientation:UIImageOrientationUp];
            CGFloat realHeight = imageCrop.size.height/imageCrop.size.width*SCREEN_WIDTH;
            [imageCrop drawInRect:CGRectMake(0, offsetY, SCREEN_WIDTH, realHeight)];
            offsetY += realHeight;
            CGImageRelease(imageCropRef);
            }
        }
    }
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}


- (IBAction)startMergeImage:(id)sender {
    
    if (self.dataSource.count == 0) {
        return;
    }
    
    if (self.dataSource.count < 2) {
         [self.view makeToast:SZLocalizedString(@"没有足够的图片拼接")];
        return;
    }
    
    
    //已经选择完图片了，但是还没有识别完成
    if (_generator.stiching) {
        _needJumpToPreviewController = YES;
        [SVProgressHUD show];
        return;
    }
    
    if (_generator.infos.count == 0) {
        return;
    }
    
    [SVProgressHUD dismiss];
     _needJumpToPreviewController = NO;
    SZImagePreVewController *vc = [[SZImagePreVewController alloc] initWithGenerator:_generator];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SZImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SZImageTableViewCell.class)];
    if (cell == nil) {
        cell = [[SZImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(SZImageTableViewCell.class)];
    }
    UIImage *image = self.dataSource[indexPath.row];
    [cell updateImage:image];
    return cell;
}


#pragma mark - M80MainIteractorDelegate
- (void)photosRequestAuthorizationFailed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SZLocalizedString(@"获取相册权限") message:SZLocalizedString(@"拼接图片需要打开相册选择图片，若需开启相册权限可以点击确定前往") delegate:self cancelButtonTitle:SZLocalizedString(@"取消") otherButtonTitles:SZLocalizedString(@"确定"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
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
    return UIEdgeInsetsMake(-10, -10, -10, -10);
}

- (void)showResult:(SZImageGenerator *)result {
    if (!result) {
        return;
    }
    _generator = result;
    //点击了拼接，而且还没结束识别的时候；
    if (_needJumpToPreviewController) {
        [self startMergeImage:nil];
    }
}

- (void)mergeBegin
{
//    [SVProgressHUD show];
}

- (void)mergeEnd
{
//    [SVProgressHUD dismiss];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass(SZImageTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(SZImageTableViewCell.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (ZWMGuideView *)guideView
{
    if (_guideView == nil) {
        _guideView = [[ZWMGuideView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _guideView.dataSource = self;
        _guideView.delegate = self;
    }
    return _guideView;
}
@end

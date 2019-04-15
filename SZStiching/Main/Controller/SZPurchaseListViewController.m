//
//  SZPurchaseListViewController.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZPurchaseListViewController.h"
#import "SZPurchaseListTableViewCell.h"
#import "SZPurchaseListModel.h"
#import "PurchaseManager.h"

@interface SZPurchaseListViewController ()<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSources;
@property (nonatomic, strong) PurchaseManager *purchaseManager;
@end

@implementation SZPurchaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GLOABLE_COLOR;
    CAGradientLayer *layer = [CAGradientLayer setGradualChangingColor:self.view colors:@[RGB(33, 46, 66),RGB_A(59, 75, 110, 0.8)]];
    [self.view.layer addSublayer:layer];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SZPurchaseListModel *model = self.dataSources[indexPath.row];
    SZPurchaseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SZPurchaseListTableViewCell.class)];
    if (cell == nil) {
        cell = [[SZPurchaseListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(SZPurchaseListTableViewCell.class)];
    }
    [cell updateCellWith:model];
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    UIView *backView = [[UIView alloc] initWithFrame:cell.bounds];
//    cell.selectedBackgroundView = backView;
//    cell.selectedBackgroundView.backgroundColor = GLOABLE_SELECT_COLOR;
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _purchaseManager = [PurchaseManager createPurchaseManager];
    [_purchaseManager requestProductId:@"5FEBEE2980DFDB9A1C78488FA132A8BF"];
}



#pragma mark Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass(SZPurchaseListTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(SZPurchaseListTableViewCell.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)dataSources {
    if (!_dataSources) {
        SZPurchaseListModel *model = [SZPurchaseListModel new];
        model.purName = SZLocalizedString(@"6元解锁最大8张图片的拼图功能");
        model.purchaseType = PurchaseSixYuanType;
        model.hasPurchase = NO;
        
        SZPurchaseListModel *model1 = [SZPurchaseListModel new];
        model1.purName = SZLocalizedString(@"12元解锁最大15张图片的拼图功能");
        model1.purchaseType = PurchaseTwelveType;
        model1.hasPurchase = NO;
        _dataSources = @[model,model1];
    }
    return _dataSources;
}
@end

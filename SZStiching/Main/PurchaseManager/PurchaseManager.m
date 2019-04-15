//
//  PurchaseManager.m
//  SZStiching
//
//  Created by chenshaozhe on 2018/11/26.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "PurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import <SVProgressHUD.h>

@interface PurchaseManager ()<
    SKPaymentTransactionObserver,
    SKProductsRequestDelegate
>

@property (nonatomic, copy) NSString *productId;
@end


@implementation PurchaseManager
+ (instancetype)createPurchaseManager {
    PurchaseManager *manager = [PurchaseManager new];
    return manager;
}


- (void)requestProductId:(NSString *)productId {
    _productId = productId;
    //添加一个交易队列观察者
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    //self.productIds是在开发者平台填写的产品id
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData:productId];
    }else{
        NSLog(@"不允许程序内付费");
    }
}

- (void)requestProductData:(NSString *)productId {
    // 去苹果服务器请求产品信息
    [SVProgressHUD show];
    
    NSArray *productArr = [[NSArray alloc]initWithObjects:productId, nil];
    
    NSSet *productSet = [NSSet setWithArray:productArr];
    
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
    
    request.delegate = self;
    [request start];
}

// 收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    
    NSArray *productArr = response.products;
    
    if ([productArr count] == 0) {
        [SVProgressHUD dismiss];
        NSLog(@"没有该商品");
        return;
    }
    
    NSLog(@"productId = %@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量 = %zd",productArr.count);
    
    SKProduct *p = nil;
    
    for (SKProduct *pro in productArr) {
        NSLog(@"description:%@",[pro description]);
        NSLog(@"localizedTitle:%@",[pro localizedTitle]);
        NSLog(@"localizedDescription:%@",[pro localizedDescription]);
        NSLog(@"price:%@",[pro price]);
        NSLog(@"productIdentifier:%@",[pro productIdentifier]);
        if ([pro.productIdentifier isEqualToString:self.productId]) {
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    //发送内购请求
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)requestDidFinish:(SKRequest *)request {
    [SVProgressHUD dismiss];
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"支付失败"];
}

// 监听购买结果

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: //交易完成
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTrasaction];
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing: //商品添加进列表
                
                break;
            case SKPaymentTransactionStateRestored: //购买过
                // 发送到苹果服务器验证凭证
                
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed: //交易失败
                
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                [SVProgressHUD showErrorWithStatus:@"购买失败"];
                break;
                
            default:
                break;
        }
    }
}

// 验证购买
- (void)verifyPurchaseWithPaymentTrasaction {
    
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    // 发送网络POST请求，对购买凭据进行验证
    //测试验证地址:https://sandbox.itunes.apple.com/verifyReceipt
    //正式验证地址:https://buy.itunes.apple.com/verifyReceipt
    NSURL *url = [NSURL URLWithString:PurchaseUrl];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    urlRequest.HTTPMethod = @"POST";
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = payloadData;
    // 提交验证请求，并获得官方的验证JSON结果 iOS9后更改了另外的一个方法
    NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    // 官方验证结果为空
    if (result == nil) {
        NSLog(@"验证失败");
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
    if (dict != nil) {
        // 比对字典中以下信息基本上可以保证数据安全
        // bundle_id , application_version , product_id , transaction_id
        NSLog(@"验证成功！购买的商品是：%@", @"_productName");
    }
    
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end

//
//  SZImageMergeInfo.m
//  SZStiching
//  提供图片合并的信息
//  Created by chenshaozhe on 2018/10/16.
//  Copyright © 2018年 chenshaozhe. All rights reserved.
//

#import "SZImageMergeInfo.h"
#import "SZImageFinger.h"
#import <objc/message.h>

static const NSString *INFO_KEY = @"INFO_KEY";
@interface SZImageMergeInfo ()
@property (nonatomic,assign)   SZImageFingerType type;

@property (nonatomic, strong) SZImageMergeInfo *crcMergeInfo;
@property (nonatomic, strong) SZImageMergeInfo *miniMergeInfo;
@end


@implementation SZImageMergeInfo
- (instancetype)infoBy:(UIImage *)firstImage
           secondImage:(UIImage *)secondImage
                  type:(SZImageFingerType)type
{
//
   SZImageMergeInfo *info_ = nil;
    if (type == SZImageFingerTypeCRC) {
        info_ = self.crcMergeInfo;
    } else if (type == SZImageFingerTypeMin) {
        info_ = self.miniMergeInfo;
    }

    SZImageMergeInfo *info = [[SZImageMergeInfo alloc] init];
    info.firstImage = firstImage;
    info.secondImage = secondImage;
    info.type = type;
    
    SZImageFinger *firstFingerprint = nil;
    SZImageFinger *secondFingerprint= [SZImageFinger fingerImage:secondImage type:type];
    if (info_.finger != nil) {
        firstFingerprint = info_.finger;
    }
    else{
        firstFingerprint = [SZImageFinger fingerImage:firstImage type:type];
    }
    //每次都是记录第二张图片的finger；
    info_.finger = secondFingerprint;
    
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    
    NSArray *firstLines = [firstFingerprint lines];
    NSArray *secondLines= [secondFingerprint lines];
    
    NSInteger firstLinesCount = (NSInteger)[firstLines count];
    NSInteger secondLinesCount = (NSInteger)[secondLines count];
    
    //初始化动态规划所需要的数组
    int **matrix = (int **)malloc(sizeof(int *) * 2);
    for (int i = 0; i < 2; i++) {
        matrix[i] = (int *)malloc(sizeof(int) * (size_t)secondLinesCount);
    }
    for (NSInteger j = 0; j < secondLinesCount; j++) {
        matrix[0][j] = matrix[1][j] = 0;
        
    }
    
    //遍历并合并
    NSInteger length = 0,x = 0,y = 0;
    //每次扫描都是从上两张图片的共同部分的起始点开始扫描。
    //这里的info_.firstOffset 代表的意思是：共同部分的最大偏移量，
    //减去info_.length就能得到：共同部分的起始位置
    NSInteger firstStartIndex = (info_.firstOffset - info_.length -10) < 0 ? 0 : (info_.firstOffset - info_.length -10);
    NSInteger secondStartIndex = 0;
    NSInteger bottomOffset = 0;
    NSInteger i = 0;
    for (NSNumber *firstLine in firstLines) {
            if (i < firstStartIndex || i > firstLinesCount - bottomOffset) {
                 i ++;
                continue;
            }
            int64_t firstValue = firstLine.integerValue;
            NSInteger j = 0;
            for (NSNumber *secondLine in secondLines) {
                    if (j < secondStartIndex || j > secondLinesCount - bottomOffset) {
                        j ++;
                        continue;
                    }
                    int64_t secondValue = secondLine.integerValue;

                    if ([info isX:firstValue
                          equalTo:secondValue]) {
                        int value = 0;
                        if (j != 0) {
                            value = matrix[(i+1) % 2][j-1] + 1;
                        }
                        matrix[i % 2][j] = value;
                        if (value > length) {
                            length = value;
                            x = i;
                            y = j;
                        }
                    }
                    else {
                        matrix[i % 2][j] = 0;
                    }
                    j ++;
            }
            i ++;
    }
 
    //清理
    for (int i = 0; i < 2; i++)
        free(matrix[i]);
    free(matrix);
    //这里的firstOffset和secondOffset是从 底 部开始的偏移量
    info.length = length;
    info.firstOffset = firstImage.size.height - (x - length + 1);
    info.secondOffset= secondImage.size.height - (y - length + 1);
    
    //这里的firstOffset和secondOffset是从 顶 部开始的偏移量
    //保存上两张图片的共同部分的最大偏移量
    info_.firstOffset = y;
    info_.length = length;
    if ([self validInfo:info]) {
        info_.firstOffset = 0;
        info_.length = 0;
    }

    CFAbsoluteTime nextTime = CFAbsoluteTimeGetCurrent() - time;
    NSLog(@"长度：%@  第一张图片x：%@  第二张图片y：%@",@(info.length),@(x),@(y));
    NSLog(@"识别最大子串耗费时间：%@",@(nextTime));
    return info;
}

- (BOOL)validInfo:(SZImageMergeInfo *)info {
    SZConstraint *contraint = [SZConstraint new];
    contraint.minImageHeight = MIN(info.firstImage.size.height, info.secondImage.size.height);
    NSInteger threshold = [contraint requiredThreshold];
    NSInteger length = info.length;
    NSLog(@"validate info [%@] threshold %zd",info,threshold);
    return threshold > 0 &&
    length > threshold &&
    info.firstOffset < info.secondOffset;
}

- (void)testPixels:(NSArray *)pixel1 pixel2:(NSArray *)pixel2{
    SZImageMergeInfo *info = [[SZImageMergeInfo alloc] init];

    NSArray *firstLines = pixel1.copy;
    NSArray *secondLines = pixel2.copy;
    NSInteger secondLinesCount = pixel2.count;
    NSInteger firstLinesCount = pixel1.count;
    //初始化动态规划所需要的数组
    int **matrix = (int **)malloc(sizeof(int *) * 2);
    for (int i = 0; i < 2; i++)
    {
        matrix[i] = (int *)malloc(sizeof(int) * (size_t)secondLinesCount);
    }
    for (NSInteger j = 0; j < secondLinesCount; j++)
    {
        matrix[0][j] = matrix[1][j] = 0;
        
    }
    
    //遍历并合并
    NSInteger length = 0,x = 0,y = 0;
    for (NSInteger i = 0; i < firstLinesCount; i ++)
    {
        for (NSInteger  j = 0; j < secondLinesCount ; j++)
        {
            int64_t firstValue = [firstLines[i] longLongValue];
            int64_t secondValue = [secondLines[j] longLongValue];
            
            if ([info isX:firstValue
                  equalTo:secondValue])
            {
                int value = 0;
                if (j != 0)
                {
                    value = matrix[(i+1) % 2][j-1] + 1;
                    printf("value ; %d \n",value);
                }
                matrix[i % 2][j] = value;
                
                if (value > length)
                {
                    length = value;
                    x = i;
                    y = j;
                }
            }
            else
            {
                matrix[i % 2][j] = 0;
            }
        }
    }
    
    //清理
    for (int i = 0; i < 2; i++)
        free(matrix[i]);
    free(matrix);
    
    info.length = length;
    info.firstOffset = pixel1.count - (x - length + 1);
    info.secondOffset= pixel2.count - (y - length + 1);

    NSLog(@"长度：%@  第一张图片offset：%@  第二张图片offset：%@",@(info.length),@(x),@(y));
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ 1st height %lf offset %zd 2nd height %lf offset %zd length %zd"
            ,_type == SZImageFingerTypeCRC ? @"crc" : @"min"
            ,_firstImage.size.height,_firstOffset,
            _secondImage.size.height,_secondOffset,
            _length];
}


- (BOOL)isX:(int64_t)x
    equalTo:(int64_t)y
{
    if (_type == SZImageFingerTypeCRC)
    {
        return x == y;
    }
    else
    {
        return x * 1.1 >= y && x * 0.9 <= y;
    }
}

- (SZImageMergeInfo *)crcMergeInfo {
    if (!_crcMergeInfo) {
        _crcMergeInfo = [SZImageMergeInfo new];
    }
    return _crcMergeInfo;
}

- (SZImageMergeInfo *)miniMergeInfo {
    if (!_miniMergeInfo) {
        _miniMergeInfo = [SZImageMergeInfo new];
    }
    return _miniMergeInfo;
}

@end

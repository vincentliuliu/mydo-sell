//
//  MSServiceInfoPrintUtil.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/30/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSServiceInfoPrintUtil.h"
#import "UIColor+HexToRGBColor.h"

#define PRICE_IMAGE_VIEW_WIDTH 100
#define PRICE_IMAGE_VIEW_HEIGHT 33
#define TIME_IMAGE_VIEW_HEIGHT 22

@implementation MSServiceInfoPrintUtil

+ (CGFloat)drawServiceInfoInViewWithNoPrice:(UIView*)canvasView point:(CGPoint)point items:(NSArray*)items interval:(CGFloat)interval
{
    return [self drawServiceInfoInView:canvasView point:point items:items interval:interval showPrice:NO];
}

+ (CGFloat)drawServiceInfoInView:(UIView*)canvasView point:(CGPoint)point items:(NSArray*)items interval:(CGFloat)interval
{
    return [self drawServiceInfoInView:canvasView point:point items:items interval:interval showPrice:YES];
}

+ (CGFloat)drawServiceInfoInView:(UIView*)canvasView point:(CGPoint)point items:(NSArray*)items interval:(CGFloat)interval showPrice:(BOOL)showPrice
{
    CGFloat startY = point.y;
    CGFloat fixedWidth = canvasView.frame.size.width-point.x*2;
    //
    CGFloat priceViewY = 0;
    CGFloat timeViewY = 0;
    // 展示动态配置数据（文字排版模板）
    for (NSDictionary *item in items) {
        NSNumber *type = [item objectForKey:@"type"];
        NSString *text = [item objectForKey:@"item"];
        // 字体、颜色、粗体
        NSString *colorValue = [item objectForKey:@"color"];
        UIColor *color = [UIColor getColorWithHexValue:colorValue];
        NSNumber *fontsize = [item objectForKey:@"fontsize"];
        NSNumber *bold = [item objectForKey:@"bold"];
        UIFont *font = nil;
        if (bold.intValue == 1) {
            font = [UIFont boldSystemFontOfSize:fontsize.floatValue];
        } else {
            font = [UIFont systemFontOfSize:fontsize.floatValue];
        }
        // 展示价格
        if ((type.intValue == 3) || (type.intValue == 4)){
            if (showPrice) {
                if (priceViewY == 0) {
                    priceViewY = startY;
                    startY = startY + PRICE_IMAGE_VIEW_HEIGHT+interval;
                }
                BOOL vipFlag = NO;
                if (type.integerValue == 4) {
                    vipFlag = YES;
                }
                [self showPricePanel:text font:font color:color point:CGPointMake(point.x, priceViewY) canvasView:canvasView vipFlag:vipFlag];
            }
        } else if ((type.intValue == 6) || (type.intValue == 7)){
        // 展示时间和适用人群
            if (timeViewY == 0) {
                timeViewY = startY+interval;
                startY = startY + TIME_IMAGE_VIEW_HEIGHT+interval*2;
            }
            BOOL timerFlag = NO;
            if (type.integerValue == 6) {
                timerFlag = YES;
            }
            [self showTimeAndUsersPanel:text font:font color:color point:CGPointMake(point.x, timeViewY) canvasView:canvasView timeFlag:timerFlag];
        } else {
        // 展示普通文本
            if ((type.integerValue == 8) || (type.integerValue == 9)) {
            // 文本定宽内容
                startY = [self showTextPanelWithFixedWidth:text font:font color:color point:CGPointMake(point.x, startY) maxWidth:fixedWidth canvasView:canvasView];
                startY += interval;
            } else {
            // 展示非定宽内容
                startY = [self showNomalTextPanel:text font:font color:color point:CGPointMake(point.x, startY) maxWidth:fixedWidth canvasView:canvasView];
                startY += interval;
            }
        }
    }
    return startY;
}

#pragma mark - Private

// 显示价格内容
+ (void)showPricePanel:(NSString*)text font:(UIFont*)font color:(UIColor*)color point:(CGPoint)point canvasView:(UIView*)canvasView vipFlag:(BOOL)vipFlag
{
    CGFloat startY = point.y;
    UIImageView *imageView = [[UIImageView alloc]init];
    [canvasView addSubview:imageView];
    UILabel *itemLabel = [[UILabel alloc]init];
    itemLabel.numberOfLines = 1;
    itemLabel.font = font;
    itemLabel.backgroundColor = [UIColor clearColor];
    itemLabel.textColor = color;
    itemLabel.text = [NSString stringWithFormat:@"￥%@", text];
    [imageView addSubview:itemLabel];
    if (vipFlag) {
        imageView.frame = CGRectMake(point.x*2+PRICE_IMAGE_VIEW_WIDTH, startY, PRICE_IMAGE_VIEW_WIDTH, PRICE_IMAGE_VIEW_HEIGHT);
        imageView.image = [UIImage imageNamed:@"VipPriceBackground"];
        //
        itemLabel.frame = CGRectMake(34, 0, PRICE_IMAGE_VIEW_WIDTH-34, PRICE_IMAGE_VIEW_HEIGHT);
    } else {
        imageView.frame = CGRectMake(point.x, startY, PRICE_IMAGE_VIEW_WIDTH, PRICE_IMAGE_VIEW_HEIGHT);
        imageView.image = [UIImage imageNamed:@"PriceBackground"];
        //
        itemLabel.frame = CGRectMake(16, 0, PRICE_IMAGE_VIEW_WIDTH-16, PRICE_IMAGE_VIEW_HEIGHT);
    }
}

// 显示时间和适用人群内容
+ (void)showTimeAndUsersPanel:(NSString*)text font:(UIFont*)font color:(UIColor*)color point:(CGPoint)point canvasView:(UIView*)canvasView timeFlag:(BOOL)timeFlag
{
    CGFloat fixedLabelWidth = 100;
    UIImageView *imageView = [[UIImageView alloc]init];
    [canvasView addSubview:imageView];
    UILabel *itemLabel = [[UILabel alloc]init];
    itemLabel.numberOfLines = 1;
    itemLabel.font = font;
    itemLabel.backgroundColor = [UIColor clearColor];
    itemLabel.textColor = color;
    itemLabel.text = text;
    [canvasView addSubview:itemLabel];
    if (timeFlag) {
        imageView.frame = CGRectMake(point.x, point.y, TIME_IMAGE_VIEW_HEIGHT, TIME_IMAGE_VIEW_HEIGHT);
        imageView.image = [UIImage imageNamed:@"TimerGrayIcon"];
    } else {
        imageView.frame = CGRectMake(point.x+TIME_IMAGE_VIEW_HEIGHT+5+fixedLabelWidth, point.y, TIME_IMAGE_VIEW_HEIGHT, TIME_IMAGE_VIEW_HEIGHT);
        imageView.image = [UIImage imageNamed:@"PeopleGrayIcon"];
    }
    itemLabel.frame = CGRectMake(imageView.frame.origin.x+TIME_IMAGE_VIEW_HEIGHT+5, point.y, fixedLabelWidth, TIME_IMAGE_VIEW_HEIGHT);
}

// 显示非定宽文本内容
+ (CGFloat)showNomalTextPanel:(NSString*)text font:(UIFont*)font color:(UIColor*)color point:(CGPoint)point maxWidth:(CGFloat)maxWidth canvasView:(UIView*)canvasView
{
    CGFloat intervalBetweenLines = 5;
    CGFloat startY = point.y;
    CGFloat localMaxWidth = maxWidth;
    // 如果内容为多行则拆成每行单独显示
    NSArray *finalOutputStrings = [text componentsSeparatedByString:@"\r\n"];
    // 计算内容的最终宽度和高度
    CGFloat finalHeight = 0;
    for (NSString *finalOutputString in finalOutputStrings) {
        CGSize size = [finalOutputString sizeWithFont:font];
        if (size.width > localMaxWidth) {
            localMaxWidth = size.width;
        }
        finalHeight = finalHeight+size.height+intervalBetweenLines;
    }
    finalHeight -= intervalBetweenLines;
    // 判断内容宽度是否超出显示宽度，否则需要加入滚动功能
    UIScrollView *tmpScrollView = nil;
    if (localMaxWidth > maxWidth) {
        tmpScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(point.x, startY, maxWidth, finalHeight)];
        tmpScrollView.showsHorizontalScrollIndicator = NO;
        tmpScrollView.showsVerticalScrollIndicator = NO;
        tmpScrollView.contentSize = CGSizeMake(localMaxWidth, finalHeight);
        [canvasView addSubview:tmpScrollView];
    }
    // 计算实际开始显示的Y坐标
    CGFloat startXInBlock = point.x;
    CGFloat startYInBlock = startY;
    if (tmpScrollView != nil) {
        startYInBlock = 0;
        startXInBlock = 0;
    }
    // 显示每行内容
    for (NSString *finalOutputString in finalOutputStrings) {
        CGSize size = [finalOutputString sizeWithFont:font];
        UILabel *itemLabel = [[UILabel alloc]initWithFrame:CGRectMake(startXInBlock, startYInBlock, size.width, size.height)];
        itemLabel.numberOfLines = 1;
        itemLabel.font = font;
        itemLabel.backgroundColor = [UIColor clearColor];
        itemLabel.textColor = color;
        itemLabel.text = finalOutputString;
        startYInBlock = startYInBlock+size.height+intervalBetweenLines;
        if (tmpScrollView != nil) {
            [tmpScrollView addSubview:itemLabel];
        } else {
            [canvasView addSubview:itemLabel];
        }
    }
    // 计算下一个元素的起始Y坐标
    return startY+finalHeight;
}

// 显示定宽文本内容
+ (CGFloat)showTextPanelWithFixedWidth:(NSString*)text font:(UIFont*)font color:(UIColor*)color point:(CGPoint)point maxWidth:(CGFloat)maxWidth canvasView:(UIView*)canvasView
{
    CGFloat startY = point.y;
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, 99999)];
    UILabel *itemLabel = [[UILabel alloc]initWithFrame:CGRectMake(point.x, startY, maxWidth, size.height)];
    itemLabel.numberOfLines = 0;
    itemLabel.font = font;
    itemLabel.backgroundColor = [UIColor clearColor];
    itemLabel.textColor = color;
    itemLabel.text = text;
    [canvasView addSubview:itemLabel];
    return startY+size.height;
}

@end

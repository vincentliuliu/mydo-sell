//
//  MSMemberCardViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSMemberCardViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "MSShareDataCache.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "UIColor+HexToRGBColor.h"
#import "MSSystemUtils.h"
#import "MSPageIndexViewController.h"
#import "MSMainViewController.h"
#import "MSShoppedItemData.h"
#import "UIImage+ScaleAndCropping.h"
#import "MSWebImageCacher.h"
#import "MSServiceInfoPrintUtil.h"

@interface MSMemberCardViewController ()

@end

@implementation MSMemberCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentPageIndex = 0;
        cardImageViews = [NSMutableArray array];
        cardShadowImage = [UIImage imageNamed:@"CardShadow"];
        linesBackgroundImage = [UIImage imageNamed:@"RandomLines"];
        defaultVipCardImage = [UIImage imageNamed:@"DefaultVipCard"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.cardInfoScrollView.backgroundColor = [UIColor getColorWithHexValue:@"f8f8f8"];
    //
    [self.shopButton setBackgroundImage:[UIImage imageNamed:@"ShopButton"] forState:UIControlStateNormal];
    [self.shopButton setBackgroundImage:[UIImage imageNamed:@"ShopButtonSelected"] forState:UIControlStateHighlighted];
    //
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    NSString *urlStr = [NSString stringWithFormat:@"%@r=mydo/getproduct&store_id=%@", HOST_DOMAIN, [userInfo objectForKey:@"store_id"]];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(cardDataRequestFinished:);
    //
    requestQueue = [[NSOperationQueue alloc]init];
    requestQueue.maxConcurrentOperationCount = 1;
    //
    [asiHttpRequest startSynchronous];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shopButtonPressed:(id)sender {
    // 包装商品数据
    NSDictionary *cardData = [cardDatas objectAtIndex:currentPageIndex];
    MSShoppedItemData *shopedItemData = [[MSShoppedItemData alloc]init];
    shopedItemData.type = 1;
    shopedItemData.itemID = ((NSNumber*)[cardData objectForKey:@"id"]).integerValue;
    shopedItemData.name = [cardData objectForKey:@"title"];
    NSNumber *price = [cardPriceList objectAtIndex:currentPageIndex];
    shopedItemData.price = price.floatValue;
    UIImageView *cardImageView = [cardImageViews objectAtIndex:currentPageIndex];
    shopedItemData.image = [cardImageView.image imageByScalingAndCroppingForSize:CGSizeMake(75, 48)];
    // 计算动画起点
    UIButton *button = sender;
    CGFloat x = button.frame.origin.x;
    x = x+self.view.frame.origin.x+self.cardInfoScrollView.frame.origin.x;
    CGFloat y = button.frame.origin.y;
    y = y+self.cardInfoScrollView.frame.origin.y-self.cardInfoScrollView.contentOffset.y;
    [self.mainViewController addToShopBag:shopedItemData position:CGPointMake(x, y)];
}

#pragma mark - Private

// 初始化会员卡图像滚动窗口
- (void)initCardImageScrollView
{
    self.cardImageScrollView.contentSize = CGSizeMake(self.cardImageScrollView.frame.size.width*cardDatas.count, self.cardImageScrollView.frame.size.height);
    CGFloat startX = 0;
    CGFloat cardBackgroundWidth = self.cardImageScrollView.frame.size.width;
    CGFloat cardBackgroundHeight = self.cardImageScrollView.frame.size.height;
    CGFloat cardImageWidth = 308;
    CGFloat cardImageHeight = 190;
    //
    int index = 0;
    for (NSDictionary *cardData in cardDatas) {
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(startX, 0, cardBackgroundWidth, cardBackgroundHeight)];
        backgroundView.backgroundColor = [UIColor getColorWithHexValue:[cardData objectForKey:@"backgroundcolor"]];
        [self.cardImageScrollView addSubview:backgroundView];
        UIImageView *linesBackgroundImageView = [[UIImageView alloc]initWithImage:linesBackgroundImage];
        linesBackgroundImageView.frame = CGRectMake(0, 0, cardBackgroundWidth, cardBackgroundHeight);
        [backgroundView addSubview:linesBackgroundImageView];
        UIImageView *cardImageView = [[UIImageView alloc]initWithFrame:CGRectMake((cardBackgroundWidth-cardImageWidth)/2, (cardBackgroundHeight-cardImageHeight)/2, cardImageWidth, cardImageHeight)];
        cardImageView.image = defaultVipCardImage;
        [backgroundView addSubview:cardImageView];
        [cardImageViews addObject:cardImageView];
        UIImageView *cardShadowImageView = [[UIImageView alloc]initWithImage:cardShadowImage];
        cardShadowImageView.frame = CGRectMake(cardImageView.frame.origin.x+cardImageWidth-cardShadowImage.size.width+50, cardImageView.frame.origin.y+cardImageHeight-cardShadowImage.size.height+18, cardShadowImage.size.width, cardShadowImage.size.height);
        [backgroundView insertSubview:cardShadowImageView belowSubview:cardImageView];
        startX += cardBackgroundWidth;
        // 异步下载会员卡图片
        [self loadCardImage:[cardData objectForKey:@"image"] index:index];
        //
        index++;
    }
}

// 刷新指定会员卡文字内容的展示
- (void)refreshCardInfoView:(NSInteger)index
{
    NSDictionary *cardData = [cardDatas objectAtIndex:index];
    self.orderedNumberLabel.text = [NSString stringWithFormat:@"已有 %@ 人订购", [cardData objectForKey:@"ordered_number"]];
    NSArray *itemDatas = [cardData objectForKey:@"items"];
    CGFloat startX = 42;
    CGFloat startY = 25;
    CGFloat verticalInterval = 5;
    // 清除已有数据
    for (UIView *subView in self.cardInfoScrollView.subviews) {
        if (subView.tag == 0) {
            [subView removeFromSuperview];
        }
    }
    self.cardInfoScrollView.contentOffset = CGPointMake(0, 0);
    // 展示动态配置数据（文字排版模板）
    startY = [MSServiceInfoPrintUtil drawServiceInfoInViewWithNoPrice:self.cardInfoScrollView point:CGPointMake(startX, startY) items:itemDatas interval:verticalInterval];
    //
    CGRect frame = self.shopButton.frame;
    frame.origin.y = startY+verticalInterval*2;
    self.shopButton.frame = frame;
    startY = startY+frame.size.height+verticalInterval*2;
    //
    CGSize contentSize = self.cardInfoScrollView.contentSize;
    contentSize.height = startY;
    self.cardInfoScrollView.contentSize = contentSize;
}

// 设置会员卡背景色列表
- (void)setupColorCellViews
{
    CGFloat cellWidth = 11;
    CGFloat horizontalInterval = 8;
    CGFloat grabSpaceWidth = cellWidth*cardDatas.count+horizontalInterval*(cardDatas.count-1);
    CGFloat rightMargin = 95;
    CGFloat startX = self.view.frame.size.width-grabSpaceWidth-rightMargin;
    for (NSDictionary *cardData in cardDatas) {
        NSString *backgroundColor = [cardData objectForKey:@"backgroundcolor"];
        UIView *colorCellView = [[UIView alloc]initWithFrame:CGRectMake(startX, 128, cellWidth, cellWidth)];
        colorCellView.backgroundColor = [UIColor getColorWithHexValue:backgroundColor];
        [self.view addSubview:colorCellView];
        startX = startX+cellWidth+horizontalInterval;
    }
}

// 异步加载会员卡图片
- (void)loadCardImage:(NSString*)imageURL index:(NSInteger)index
{
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:imageURL];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index], @"index", nil];
        request.didFinishSelector = @selector(cardImageRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        UIImageView *cardImageView = [cardImageViews objectAtIndex:index];
        cardImageView.image = cachedImage;
    }
}

// 设置分页指示器
- (void)setupPageIndexIndicator
{
    pageIndexViewController = [[MSPageIndexViewController alloc]initWithNibName:@"MSPageIndexViewController" bundle:nil pageCount:cardDatas.count];
    CGRect frame = pageIndexViewController.view.frame;
    frame.origin.y = PAGE_VIEW_CONTROLLER_FRAME_Y;
    frame.origin.x = (self.view.frame.size.width-frame.size.width)/2;
    pageIndexViewController.view.frame = frame;
    [self.view addSubview:pageIndexViewController.view];
}

// 获取会员卡的价格列表

- (void)initCardPriceList
{
    cardPriceList = [NSMutableArray array];
    for (NSDictionary *cardData in cardDatas) {
        NSArray *cardItemDatas = [cardData objectForKey:@"items"];
        CGFloat price = [self getCardPrice:cardItemDatas];
        [cardPriceList addObject:[NSNumber numberWithFloat:price]];
    }
}

// 获取会员卡的价格
- (CGFloat)getCardPrice:(NSArray*)cardItemDatas
{
    for (NSDictionary *cardItemData in cardItemDatas) {
        NSNumber *type = [cardItemData objectForKey:@"type"];
        if (type.intValue == 3) {
            NSString *item = [cardItemData objectForKey:@"item"];
            return item.floatValue;
        }
    }
    return 0;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    if (pageIndex != currentPageIndex) {
        [self refreshCardInfoView:pageIndex];
        [pageIndexViewController moveTo:pageIndex];
        currentPageIndex = pageIndex;
    }
}

#pragma mark - ASIHttpRequest Delegate

- (void)cardDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString]; 
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        cardDatas = [resultData objectForKey:@"cards"];
        [self initCardPriceList];
        [self initCardImageScrollView];
        [self setupColorCellViews];
        [self setupPageIndexIndicator];
        [self refreshCardInfoView:currentPageIndex];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)cardImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    NSNumber *index = [request.userInfo objectForKey:@"index"];
    UIImageView *cardImageView = [cardImageViews objectAtIndex:index.intValue];
    cardImageView.image = image;
    [MSWebImageCacher cacheWebImage:request.url.description image:image];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error.code != 4) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"数据下载失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSLog(@"HttpRequestError:%@", error.description);
    }
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
}
@end

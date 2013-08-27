//
//  MSSolutionDetailViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/29/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSolutionDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Constants.h"
#import "MSShareDataCache.h"
#import "MSSystemUtils.h"
#import "MSWebImageCacher.h"
#import "UIColor+HexToRGBColor.h"
#import "MSMainViewController.h"
#import "MSServiceInfoPrintUtil.h"
#import "MSShoppedItemData.h"

@interface MSSolutionDetailViewController ()

@end

@implementation MSSolutionDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)setupServiceInfoView
{
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    //
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getsolution&solution_id=%d&store_id=%@", HOST_DOMAIN, serviceID, [userInfo objectForKey:@"store_id"]];
    NSLog(@"%@", solutionURLStr);
    NSURL *url = [NSURL URLWithString:solutionURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(serviceDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)setupServiceInfoView:(NSDictionary*)serviceInfo
{
    serviceData = serviceInfo;
    [self drawServiceInfo:[serviceData objectForKey:@"items"]];
    [self setupOperationFlowView:[serviceData objectForKey:@"operation_flow"]];
    //
    NSString *imageURL = [serviceData objectForKey:@"image"];
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:imageURL];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.didFinishSelector = @selector(serviceImageRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        self.imageView.image = cachedImage;
    }
}

- (void)drawServiceInfo:(NSArray*)serviceItemDatas
{
    CGFloat startX = 20;
    CGFloat startY = 160;
    CGFloat verticalInterval = 20;
    startY = [MSServiceInfoPrintUtil drawServiceInfoInView:self.infoScrollView point:CGPointMake(startX, startY) items:serviceItemDatas interval:verticalInterval];
    //
    UIImage *shopButtonImage = [UIImage imageNamed:@"ShopButton"];
    UIImage *shopButtonSelectedImage = [UIImage imageNamed:@"ShopButtonSelected"];
    UIImage *operationFlowButtonImage = [UIImage imageNamed:@"OperationFlow"];
    UIImage *operationFlowButtonSelectedImage = [UIImage imageNamed:@"OperationFlowSelected"];
    //
    startY += verticalInterval;
    UIView *separateLine = [[UIView alloc]initWithFrame:CGRectMake(startX, startY, self.infoScrollView.frame.size.width-startX*2, 1)];
    separateLine.backgroundColor = [UIColor getColorWithHexValue:@"e2e0e0"];
    [self.infoScrollView addSubview:separateLine];
    //
    startY += 40;
    CGFloat horizontalInterval = 50;
    //
    if (!self.shoppingIsNotAllowed) {
        shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shopButton.frame = CGRectMake(startX, startY, shopButtonImage.size.width, shopButtonImage.size.height);
        [shopButton setImage:shopButtonImage forState:UIControlStateNormal];
        [shopButton setImage:shopButtonSelectedImage forState:UIControlStateHighlighted];
        [shopButton addTarget:self action:@selector(shopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoScrollView addSubview:shopButton];
        startX = startX+shopButtonImage.size.width+horizontalInterval;
    }
    operationFlowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    operationFlowButton.frame = CGRectMake(startX, startY, shopButtonImage.size.width, shopButtonImage.size.height);
    [operationFlowButton setImage:operationFlowButtonImage forState:UIControlStateNormal];
    [operationFlowButton setImage:operationFlowButtonSelectedImage forState:UIControlStateHighlighted];
    [operationFlowButton addTarget:self action:@selector(operationFlowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoScrollView addSubview:operationFlowButton];
}

- (void)operationFlowButtonPressed:(id)sender
{
    CGRect frame = self.view.frame;
    frame.origin.x -= self.operationFlowView.frame.size.width;
    [UIView beginAnimations:@"OperationFlowViewAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(operationFlowViewShowAnimationDone:finished:context:)];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)operationFlowViewShowAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    UIControl *control = [[UIControl alloc]initWithFrame:CGRectMake(self.operationFlowView.frame.size.width, 0, self.view.frame.size.width-self.operationFlowView.frame.size.width*2, self.view.frame.size.height)];
    control.backgroundColor = [UIColor darkGrayColor];
    control.alpha = 0.3;
    [control addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:control];
}

- (void)controlPressed:(id)sender
{
    UIControl *control = sender;
    [control removeFromSuperview];
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    [UIView beginAnimations:@"OperationFlowViewAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)setupOperationFlowView:(NSArray*)items
{
    CGFloat startY = 120;
    CGFloat margin = 0;
    CGFloat horizontalInterval = 10;
    CGFloat verticalInterval = 30;
    CGFloat adjustSpace = 80;
    CGFloat labelWidth = (self.operationFlowView.frame.size.width-margin*2-horizontalInterval*2-adjustSpace)/2;
    CGFloat labelHeight = 13;
    UIImage *nodeIcon = [UIImage imageNamed:@"FlowNodeIcon"];
    UIImage *flowLine = [UIImage imageNamed:@"FlowLine"];
    flowLine = [flowLine stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    //
    int i = 1;
    for (NSDictionary *item in items) {
        NSString *nodeName = [item objectForKey:@"progress_name"];
        UILabel *nodeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, startY, labelWidth, labelHeight)];
        nodeNameLabel.backgroundColor = [UIColor clearColor];
        nodeNameLabel.textAlignment = NSTextAlignmentRight;
        nodeNameLabel.textColor = [UIColor getColorWithHexValue:@"979797"];
        nodeNameLabel.font = [UIFont systemFontOfSize:15];
        nodeNameLabel.text = nodeName;
        nodeNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.operationFlowView addSubview:nodeNameLabel];
        //
        UIImageView *nodeImageView = [[UIImageView alloc]initWithImage:nodeIcon];
        nodeImageView.frame = CGRectMake(margin+labelWidth+horizontalInterval, startY, nodeIcon.size.width, nodeIcon.size.height);
        [self.operationFlowView addSubview:nodeImageView];
        //
        if (i < items.count) {
            CGFloat flowLineHeight = labelHeight+verticalInterval-nodeIcon.size.height;
            UIImageView *flowLineImageView = [[UIImageView alloc]initWithImage:flowLine];
            flowLineImageView.frame = CGRectMake(nodeImageView.frame.origin.x+(nodeImageView.frame.size.width-flowLine.size.width)/2, nodeImageView.frame.origin.y+nodeIcon.size.height, flowLine.size.width, flowLineHeight);
            [self.operationFlowView addSubview:flowLineImageView];
        }
        //
        NSString *material = [item objectForKey:@"material"];
        UILabel *materialLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin+labelWidth+horizontalInterval*2+nodeIcon.size.width, startY, labelWidth+adjustSpace, labelHeight)];
        materialLabel.backgroundColor = [UIColor clearColor];
        materialLabel.textColor = [UIColor getColorWithHexValue:@"babcbb"];
        materialLabel.font = [UIFont systemFontOfSize:15];
        materialLabel.text = material;
        materialLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.operationFlowView addSubview:materialLabel];
        //
        startY = startY+labelHeight+verticalInterval;
        i++;
    }
}

- (IBAction)shopButtonPressed:(id)sender {
    // 包装商品数据
    NSString *thumb = [serviceData objectForKey:@"thumb"];
    MSShoppedItemData *shopedItemData = [[MSShoppedItemData alloc]init];
    shopedItemData.type = 2;
    shopedItemData.itemID = ((NSNumber*)[serviceData objectForKey:@"id"]).integerValue;
    shopedItemData.name = [serviceData objectForKey:@"title"];
    CGPoint point = [self getServicePrice:[serviceData objectForKey:@"items"]];
    shopedItemData.price = point.x;
    shopedItemData.priceForVIP = point.y;
    shopedItemData.image = [MSWebImageCacher getCacheImage:[MSSystemUtils getPropertyImageURL:thumb]];
    // 计算动画起点
    UIButton *button = sender;
    CGFloat x = button.frame.origin.x;
    x = x+self.infoScrollView.frame.origin.x;
    CGFloat y = button.frame.origin.y;
    [self.mainViewController addToShopBag:shopedItemData position:CGPointMake(x, y)];
}

- (CGPoint)getServicePrice:(NSArray*)items
{
    CGFloat price = 0;
    CGFloat priceVip = 0;
    for (NSDictionary *item in items) {
        NSNumber *type = [item objectForKey:@"type"];
        NSString *text = [item objectForKey:@"item"];
        if (type.integerValue == 3) {
            price = text.floatValue;
        } else if (type.integerValue == 4) {
            priceVip = text.floatValue;
        }
    }
    return CGPointMake(price, priceVip);
}

#pragma mark - ASIHttpRequest Delegate

- (void)serviceDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupServiceInfoView:[resultData objectForKey:@"service_info"]];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)serviceImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    self.imageView.image = image;
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

@end

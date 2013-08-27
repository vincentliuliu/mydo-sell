//
//  MSCustomizeSolutionDetailViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSCustomizeSolutionDetailViewController.h"
#import "MSShareDataCache.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Constants.h"
#import "MSSystemUtils.h"
#import "MSWebImageCacher.h"
#import "UIColor+HexToRGBColor.h"
#import "MSServiceInfoPrintUtil.h"
#import "MSMainViewController.h"
#import "MSShoppedItemData.h"
#import "MSSolutionDetailViewController.h"

@interface MSCustomizeSolutionDetailViewController ()

@end

@implementation MSCustomizeSolutionDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getservice&service_id=%d&store_id=%@", HOST_DOMAIN, serviceID, [userInfo objectForKey:@"store_id"]];
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
    [self setupComponentsView:[serviceData objectForKey:@"components"]];
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
    UIImage *operationFlowButtonImage = [UIImage imageNamed:@"ComponentsButton"];
    UIImage *operationFlowButtonSelectedImage = [UIImage imageNamed:@"ComponentsSelectedButton"];
    //
    startY += verticalInterval;
    UIView *separateLine = [[UIView alloc]initWithFrame:CGRectMake(startX, startY, self.infoScrollView.frame.size.width-startX*2, 1)];
    separateLine.backgroundColor = [UIColor getColorWithHexValue:@"e2e0e0"];
    [self.infoScrollView addSubview:separateLine];
    //
    startY += 40;
    CGFloat horizontalInterval = 50;
    //
    shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shopButton.frame = CGRectMake(startX, startY, shopButtonImage.size.width, shopButtonImage.size.height);
    [shopButton setImage:shopButtonImage forState:UIControlStateNormal];
    [shopButton setImage:shopButtonSelectedImage forState:UIControlStateHighlighted];
    [shopButton addTarget:self action:@selector(shopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoScrollView addSubview:shopButton];
    componentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    componentsButton.frame = CGRectMake(startX+shopButtonImage.size.width+horizontalInterval, startY, shopButtonImage.size.width, shopButtonImage.size.height);
    [componentsButton setImage:operationFlowButtonImage forState:UIControlStateNormal];
    [componentsButton setImage:operationFlowButtonSelectedImage forState:UIControlStateHighlighted];
    [componentsButton addTarget:self action:@selector(componentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoScrollView addSubview:componentsButton];
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

- (void)componentsButtonPressed:(id)sender
{
    CGRect frame = self.view.frame;
    frame.origin.x -= self.componentsView.frame.size.width;
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
    UIControl *control = [[UIControl alloc]initWithFrame:CGRectMake(self.componentsView.frame.size.width, 0, self.view.frame.size.width-self.componentsView.frame.size.width*2, self.view.frame.size.height)];
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

- (void)setupComponentsView:(NSArray*)items
{
    UIImage *nodeIcon = [UIImage imageNamed:@"FlowNodeIcon"];
    UIImage *flowLine = [UIImage imageNamed:@"FlowLine"];
    CGFloat startY = 120;
    CGFloat margin = 10;
    CGFloat verticalInterval = 30;
    CGFloat maxButtonWidth = self.componentsView.frame.size.width-margin*3-nodeIcon.size.width;
    CGFloat buttonHeight = 13;
    flowLine = [flowLine stretchableImageWithLeftCapWidth:0 topCapHeight:1];
    //
    int i = 1;
    for (NSDictionary *item in items) {
        UIImageView *nodeImageView = [[UIImageView alloc]initWithImage:nodeIcon];
        nodeImageView.frame = CGRectMake(margin, startY, nodeIcon.size.width, nodeIcon.size.height);
        [self.componentsView addSubview:nodeImageView];
        //
        if (i < items.count) {
            CGFloat flowLineHeight = buttonHeight+verticalInterval-nodeIcon.size.height;
            UIImageView *flowLineImageView = [[UIImageView alloc]initWithImage:flowLine];
            flowLineImageView.frame = CGRectMake(nodeImageView.frame.origin.x+(nodeImageView.frame.size.width-flowLine.size.width)/2, nodeImageView.frame.origin.y+nodeIcon.size.height, flowLine.size.width, flowLineHeight);
            [self.componentsView addSubview:flowLineImageView];
        }
        //
        NSNumber *nodeID = [item objectForKey:@"id"];
        NSString *nodeName = [item objectForKey:@"component_name"];
        UIButton *componentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        componentButton.frame = CGRectMake(margin*2+nodeIcon.size.width, startY, maxButtonWidth, buttonHeight);
        componentButton.backgroundColor = [UIColor clearColor];
        [componentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [componentButton setTitleColor:[UIColor getColorWithHexValue:@"babcbb"] forState:UIControlStateHighlighted];
        componentButton.titleLabel.font = [UIFont systemFontOfSize:15];
        componentButton.tag = nodeID.integerValue;
        componentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [componentButton setTitle:nodeName forState:UIControlStateNormal];
        [componentButton addTarget:self action:@selector(componentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.componentsView addSubview:componentButton];
        //
        startY = startY+buttonHeight+verticalInterval;
        i++;
    }
}

- (void)componentButtonPressed:(id)sender
{
    UIButton *button = sender;
    MSSolutionDetailViewController *solutionDetailViewController = [[MSSolutionDetailViewController alloc]initWithNibName:@"MSSolutionDetailViewController" bundle:nil serviceID:button.tag];
    solutionDetailViewController.mainViewController = self.mainViewController;
    solutionDetailViewController.shoppingIsNotAllowed = YES;
    [self.mainViewController enterServiceDetailView:solutionDetailViewController selector:@selector(setupServiceInfoView)];
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

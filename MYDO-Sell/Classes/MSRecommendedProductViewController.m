//
//  MSRecommendedProductViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/27/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSRecommendedProductViewController.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MSServiceListViewController.h"
#import "MSSystemUtils.h"
#import "UIColor+HexToRGBColor.h"
#import "MSServiceData.h"
#import "MSMainViewController.h"
#import "MSPageIndexViewController.h"
#import "MSShareDataCache.h"
#import "MSRecommendedProductDetailViewController.h"

@interface MSRecommendedProductViewController ()

@end

@implementation MSRecommendedProductViewController

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
    NSString *categoryURLStr = [NSString stringWithFormat:@"%@r=mydo/getboutiques&store_id=%@", HOST_DOMAIN, [[MSShareDataCache getUserInfo] objectForKey:@"store_id"]];
    NSLog(@"%@", categoryURLStr);
    NSURL *url = [NSURL URLWithString:categoryURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(recommendedProductDataRequestFinished:);
    [asiHttpRequest startSynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupServiceListView:(NSArray*)serviceDatas
{
    NSArray *convertedDatas = [self getConvertedServiceDataForList:serviceDatas];
    serviceListViewController = [[MSServiceListViewController alloc]initWithNibName:@"MSServiceListViewController" bundle:nil serviceDatas:convertedDatas];
    serviceListViewController.callbackDelegate = self;
    [self.view addSubview:serviceListViewController.view];
}

// 获取产品包装后用于构建列表窗口的数据
- (NSArray*)getConvertedServiceDataForList:(NSArray*)productDatas
{
    NSMutableArray *convertedDatas = [NSMutableArray array];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
    UIColor *titleColor = [UIColor getColorWithHexValue:@"3ab2c3"];
    UIFont *subtitleFont = [UIFont boldSystemFontOfSize:16];
    UIColor *subtitleColor = [UIColor getColorWithHexValue:@"646668"];
    UIFont *orderNumberFont = [UIFont systemFontOfSize:15];
    UIColor *orderNumberColor = [UIColor getColorWithHexValue:@"a7a9ac"];
    for (NSDictionary *productData in productDatas) {
        NSMutableArray *itemDatas = [NSMutableArray array];
        NSString *title = [productData objectForKey:@"title"];
        MSStateItemData *itemData = [[MSStateItemData alloc]initWithTitle:title font:titleFont color:titleColor icon:nil topSpace:30 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        NSString *subtitle = [productData objectForKey:@"subtitle"];
        itemData = [[MSStateItemData alloc]initWithTitle:subtitle font:subtitleFont color:subtitleColor icon:nil topSpace:15 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        NSNumber *orderNumber = [productData objectForKey:@"ordered_number"];
        itemData = [[MSStateItemData alloc]initWithTitle:[NSString stringWithFormat:@"已有 %d 人选购", orderNumber.integerValue] font:orderNumberFont color:orderNumberColor icon:nil topSpace:40 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        //
        NSNumber *storeID = [productData objectForKey:@"id"];
        MSServiceData *serviceData = [[MSServiceData alloc]initWithServiceID:storeID.integerValue imageURL:[productData objectForKey:@"image"] stateItems:itemDatas];
        [convertedDatas addObject:serviceData];
    }
    return convertedDatas;
}

// 设置分页指示器
- (void)setupPageIndexIndicator
{
    pageIndexViewController = [[MSPageIndexViewController alloc]initWithNibName:@"MSPageIndexViewController" bundle:nil pageCount:serviceListViewController.pageCount];
    CGRect frame = pageIndexViewController.view.frame;
    frame.origin.y = PAGE_VIEW_CONTROLLER_FRAME_Y;
    frame.origin.x = (self.view.frame.size.width-frame.size.width)/2;
    pageIndexViewController.view.frame = frame;
    [self.view addSubview:pageIndexViewController.view];
}

#pragma mark - ASIHttpRequest Delegate

- (void)recommendedProductDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupServiceListView:[resultData objectForKey:@"services"]];
        [self setupPageIndexIndicator];
        [serviceListViewController loadServiceImages];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
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

#pragma mark - ServiceListCallBack Delegate

- (void)serviceListScrollCallBack:(NSInteger)pageIndex
{
    [pageIndexViewController moveTo:pageIndex];
}

- (void)serviceListTouchCallBack:(NSInteger)serviceID
{
    recommendedProductViewController = [[MSRecommendedProductDetailViewController alloc]initWithNibName:@"MSRecommendedProductDetailViewController" bundle:nil serviceID:serviceID];
    recommendedProductViewController.mainViewController = self.mainViewController;
    [self.mainViewController enterServiceDetailView:recommendedProductViewController selector:@selector(setupServiceInfoView)];
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
}

@end

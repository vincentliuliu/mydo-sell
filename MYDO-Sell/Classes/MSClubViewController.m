//
//  MSClubViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSClubViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MSShareDataCache.h"
#import "MSServiceData.h"
#import "MSServiceListViewController.h"
#import "MSPageIndexViewController.h"
#import "MSClubDetailViewController.h"
#import "MSMainViewController.h"

@interface MSClubViewController ()

@end

@implementation MSClubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
        //
        locationIcon = [UIImage imageNamed:@"LocationIcon"];
        timeIcon = [UIImage imageNamed:@"TimeIcon"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self makeTheButtonSelected:self.currentSlansButton];
    [self makeTheButtonUnselected:self.expiredSalonsButton];
    //
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    //
    NSString *salonsURLStr = [NSString stringWithFormat:@"%@r=mydo/getsalons&store_id=%@", HOST_DOMAIN, [userInfo objectForKey:@"store_id"]];
    NSLog(@"%@", salonsURLStr);
    NSURL *url = [NSURL URLWithString:salonsURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(salonsDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)makeTheButtonSelected:(UIButton*)button
{
    button.backgroundColor = [UIColor getColorWithHexValue:BASE_COLOR_VALUE];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor getColorWithHexValue:@"a4a5a5"] forState:UIControlStateHighlighted];
}

- (void)makeTheButtonUnselected:(UIButton*)button
{
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor getColorWithHexValue:@"a4a5a5"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

- (IBAction)currentSalonsButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        [self makeTheButtonSelected:button];
        [self makeTheButtonUnselected:self.expiredSalonsButton];
        button.tag = 1;
        self.expiredSalonsButton.tag = 0;
        [self setupCurrentSalonListView:currentConvertedSalonDatas canPressed:NO];
        [pageIndexViewController resetPageCount:serviceListViewController.pageCount];
    }
}

- (IBAction)expiredSalonsButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        [self makeTheButtonSelected:button];
        [self makeTheButtonUnselected:self.currentSlansButton];
        button.tag = 1;
        self.currentSlansButton.tag = 0;
        [self setupCurrentSalonListView:expiredSalonConvertedDatas canPressed:YES];
        [pageIndexViewController resetPageCount:serviceListViewController.pageCount];
    }
}

// 获取当前活动包装后用于构建列表窗口的数据
- (NSArray*)getSalonConvertedDatasForList:(NSArray*)salonDatas
{
    NSMutableArray *convertedSalonDatas = [NSMutableArray array];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
    UIColor *titleColor = [UIColor getColorWithHexValue:@"3ab2c3"];
    UIFont *subtitleFont = [UIFont boldSystemFontOfSize:16];
    UIColor *subtitleColor = [UIColor getColorWithHexValue:@"646668"];
    UIFont *limitedNumberFont = [UIFont systemFontOfSize:15];
    UIColor *limitedNumberColor = [UIColor getColorWithHexValue:@"a7a9ac"];
    for (NSDictionary *salonData in salonDatas) {
        NSMutableArray *itemDatas = [NSMutableArray array];
        NSString *title = [salonData objectForKey:@"title"];
        MSStateItemData *itemData = [[MSStateItemData alloc]initWithTitle:title font:titleFont color:titleColor icon:nil topSpace:30 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        NSString *subtitle = [salonData objectForKey:@"subtitle"];
        itemData = [[MSStateItemData alloc]initWithTitle:subtitle font:subtitleFont color:subtitleColor icon:nil topSpace:10 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        NSNumber *limitedNumber = [salonData objectForKey:@"limited_number"];
        itemData = [[MSStateItemData alloc]initWithTitle:[NSString stringWithFormat:@"限定人数：%@", limitedNumber] font:limitedNumberFont color:limitedNumberColor icon:nil topSpace:10 textAlignment:NSTextAlignmentCenter singleLine:YES];
        [itemDatas addObject:itemData];
        NSString *address = [salonData objectForKey:@"address"];
        itemData = [[MSStateItemData alloc]initWithTitle:address font:limitedNumberFont color:limitedNumberColor icon:locationIcon topSpace:10 textAlignment:NSTextAlignmentLeft singleLine:YES];
        [itemDatas addObject:itemData];
        NSString *date = [salonData objectForKey:@"date"];
        itemData = [[MSStateItemData alloc]initWithTitle:date font:limitedNumberFont color:limitedNumberColor icon:timeIcon topSpace:5 textAlignment:NSTextAlignmentLeft singleLine:YES];
        [itemDatas addObject:itemData];
        NSString *description = [salonData objectForKey:@"description"];
        itemData = [[MSStateItemData alloc]initWithTitle:description font:limitedNumberFont color:[UIColor grayColor] icon:nil topSpace:15 textAlignment:NSTextAlignmentLeft singleLine:NO];
        [itemDatas addObject:itemData];
        //
        NSNumber *storeID = [salonData objectForKey:@"id"];
        MSServiceData *serviceData = [[MSServiceData alloc]initWithServiceID:storeID.integerValue imageURL:[salonData objectForKey:@"image"] stateItems:itemDatas];
        [convertedSalonDatas addObject:serviceData];
    }
    return convertedSalonDatas;
}

- (void)setupCurrentSalonListView:(NSArray*)convertedSalonDatas canPressed:(BOOL)canPressed
{
    if (serviceListViewController) {
        [serviceListViewController cancelAllOperations];
        [serviceListViewController.view removeFromSuperview];
        serviceListViewController = nil;
    }
    serviceListViewController = [[MSServiceListViewController alloc]initWithNibName:@"MSServiceListViewController" bundle:nil serviceDatas:convertedSalonDatas];
    serviceListViewController.canNotBePressed = !canPressed;
    serviceListViewController.callbackDelegate = self;
    [self.view addSubview:serviceListViewController.view];
    [serviceListViewController loadServiceImages];
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

- (void)salonsDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        currentConvertedSalonDatas = [self getSalonConvertedDatasForList:[resultData objectForKey:@"current_salons"]];
        expiredSalonConvertedDatas = [self getSalonConvertedDatasForList:[resultData objectForKey:@"expired_salons"]];
        [self setupCurrentSalonListView:currentConvertedSalonDatas canPressed:NO];
        [self setupPageIndexIndicator];
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
    if (self.expiredSalonsButton.tag == 1) {
        clubDetailViewController = [[MSClubDetailViewController alloc]initWithNibName:@"MSClubDetailViewController" bundle:nil serviceID:serviceID];
        clubDetailViewController.mainViewController = self.mainViewController;
        [self.mainViewController enterServiceDetailView:clubDetailViewController selector:@selector(setupServiceInfoView)];
    }
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
}

@end

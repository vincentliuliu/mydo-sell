//
//  MSCustomizeSolutionViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSCustomizeSolutionViewController.h"
#import "Constants.h"
#import "MSShareDataCache.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "UIColor+HexToRGBColor.h"
#import "MSServiceListViewController.h"
#import "MSServiceData.h"
#import "MSPageIndexViewController.h"
#import "MSCustomizeSolutionDetailViewController.h"
#import "MSMainViewController.h"

@interface MSCustomizeSolutionViewController ()

@end

@implementation MSCustomizeSolutionViewController

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
    NSString *categoryURLStr = [NSString stringWithFormat:@"%@r=mydo/getservicetypes&store_id=%@", HOST_DOMAIN, [[MSShareDataCache getUserInfo] objectForKey:@"store_id"]];
    NSLog(@"%@", categoryURLStr);
    NSURL *url = [NSURL URLWithString:categoryURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(categoryDataRequestFinished:);
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
    button.tag = 1;
    button.backgroundColor = [UIColor getColorWithHexValue:BASE_COLOR_VALUE];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor getColorWithHexValue:@"a4a5a5"] forState:UIControlStateHighlighted];
}

- (void)makeTheButtonUnselected:(UIButton*)button
{
    button.tag = 0;
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor getColorWithHexValue:@"a4a5a5"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

- (void)menuButtonPressed:(id)sender
{
    UIButton *button = sender;
    if (button.tag == 0) {
        for (UIButton *menuButton in menuButtons) {
            if (menuButton != button) {
                [self makeTheButtonUnselected:menuButton];
            }
        }
        [self makeTheButtonSelected:button];
        [self loadCustomizedSolutions:button.titleLabel.tag];
        [pageIndexViewController resetPageCount:serviceListViewController.pageCount];
    }
}

- (void)setupTypeMenus:(NSArray*)typeDatas
{
    menuButtons = [NSMutableArray array];
    CGFloat maxWidth = 0;
    CGFloat horizontalInterval = 10;
    CGFloat startY = 164;
    CGFloat menuHeight = 26;
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    for (NSDictionary *typeData in typeDatas) {
        NSString *caption = [typeData objectForKey:@"caption"];
        CGSize size = [caption sizeWithFont:font];
        if (size.width > maxWidth) {
            maxWidth = size.width;
        }
    }
    maxWidth += 40;
    CGFloat startX = self.view.frame.size.width-maxWidth-horizontalInterval*4;
    //
    for (int i=typeDatas.count-1; i>-1; i--) {
        NSDictionary *typeData = [typeDatas objectAtIndex:i];
        NSNumber *typeID = [typeData objectForKey:@"id"];
        NSString *caption = [typeData objectForKey:@"caption"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(startX, startY, maxWidth, menuHeight);
        button.titleLabel.font = font;
        button.titleLabel.tag = typeID.integerValue;
        [button setTitle:caption forState:UIControlStateNormal];
        [button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [menuButtons addObject:button];
        if (i == 0) {
            [self makeTheButtonSelected:button];
            [self loadCustomizedSolutions:typeID.integerValue];
        } else {
            [self makeTheButtonUnselected:button];
        }
        startX = startX-maxWidth-horizontalInterval;
    }
}

- (void)loadCustomizedSolutions:(NSInteger)typeID
{
    NSString *servicesURLStr = [NSString stringWithFormat:@"%@r=mydo/getservices&service_type_id=%d&store_id=%@", HOST_DOMAIN, typeID, [[MSShareDataCache getUserInfo] objectForKey:@"store_id"]];
    NSLog(@"%@", servicesURLStr);
    NSURL *url = [NSURL URLWithString:servicesURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(servicesDataRequestFinished:);
    [asiHttpRequest startSynchronous];
}

- (void)setupProductListView:(NSArray*)productDatas
{
    NSArray *convertedDatas = [self getConvertedProductDataForList:productDatas];
    if (serviceListViewController) {
        [serviceListViewController cancelAllOperations];
        [serviceListViewController.view removeFromSuperview];
        serviceListViewController = nil;
    }
    serviceListViewController = [[MSServiceListViewController alloc]initWithNibName:@"MSServiceListViewController" bundle:nil serviceDatas:convertedDatas];
    serviceListViewController.callbackDelegate = self;
    [self.view addSubview:serviceListViewController.view];
    [serviceListViewController loadServiceImages];
}

// 获取产品包装后用于构建列表窗口的数据
- (NSArray*)getConvertedProductDataForList:(NSArray*)productDatas
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
        NSNumber *productID = [productData objectForKey:@"id"];
        MSServiceData *serviceData = [[MSServiceData alloc]initWithServiceID:productID.integerValue imageURL:[productData objectForKey:@"image"] stateItems:itemDatas];
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

- (void)categoryDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupTypeMenus:[resultData objectForKey:@"types"]];
        [self setupPageIndexIndicator];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)servicesDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupProductListView:[resultData objectForKey:@"services"]];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

#pragma mark - ServiceListCallBack Delegate

- (void)serviceListScrollCallBack:(NSInteger)pageIndex
{
    [pageIndexViewController moveTo:pageIndex];
}

- (void)serviceListTouchCallBack:(NSInteger)serviceID
{
    customizeSolutionDetailViewController = [[MSCustomizeSolutionDetailViewController alloc]initWithNibName:@"MSCustomizeSolutionDetailViewController" bundle:nil serviceID:serviceID];
    customizeSolutionDetailViewController.mainViewController = self.mainViewController;
    [self.mainViewController enterServiceDetailView:customizeSolutionDetailViewController selector:@selector(setupServiceInfoView)];
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
}

@end

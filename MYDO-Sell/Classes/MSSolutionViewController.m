//
//  MSSolutionViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSolutionViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MSShareDataCache.h"
#import "MSSystemUtils.h"
#import "MSWebImageCacher.h"
#import "MSServiceListViewController.h"
#import "MSServiceData.h"
#import "MSPageIndexViewController.h"
#import "MSSolutionDetailViewController.h"
#import "MSMainViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MENUBACKGROUND_HEIGHT 120
#define MENUBACKGROUND_WIDTH 680
#define MENU_ITEM_HEIGHT 40
#define MENU_ITEM_WIDTH 170

@interface MSSolutionViewController ()

@end

@implementation MSSolutionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        submenuScrollViewArray = [NSMutableArray array];
        //
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.moreButton setImage:[UIImage imageNamed:@"MoreButton"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"MoreButtonSelected"] forState:UIControlStateHighlighted];
    //
    menuBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, self.moreButton.frame.origin.y-MENUBACKGROUND_HEIGHT+self.moreButton.frame.size.height+10, MENUBACKGROUND_WIDTH, MENUBACKGROUND_HEIGHT)];
    menuBackgroundView.backgroundColor = [UIColor blackColor];
    menuBackgroundView.layer.borderWidth = 2;
    menuBackgroundView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    menuBackgroundView.tag = -1;
    [self.view addSubview:menuBackgroundView];
    //
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    //
    NSString *categoryURLStr = [NSString stringWithFormat:@"%@r=mydo/getsolutioncategory&store_id=%@", HOST_DOMAIN, [userInfo objectForKey:@"store_id"]];
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

- (void)mainViewCallBack:(NSDictionary *)data
{
    NSString *type = [data objectForKey:MAINVIEW_CALLBACK_ACTION_TYPE];
    if ([type isEqualToString:MAINACTION_SHOPBAG_BUTTON_DOWN]) {
        [self hideMenuBackgroundView];
    }
}

- (IBAction)moreButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 1) {
        [self hideMenuBackgroundView];
        button.tag = 0;
    } else {
        [self showMenuBackgroundView];
        button.tag =1;
    }
}

#pragma mark - Private

- (void)hideMenuBackgroundView
{
    if (menuBackgroundView.tag == 0) {
        CGRect frame = menuBackgroundView.frame;
        frame.origin.x = self.view.frame.size.width;
        [UIView beginAnimations:@"MenuBackgroundHide" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        menuBackgroundView.frame = frame;
        [UIView commitAnimations];
        menuBackgroundView.tag = -1;
    }
}

- (void)showMenuBackgroundView
{
    if (menuBackgroundView.tag == -1) {
        CGRect frame = menuBackgroundView.frame;
        frame.origin.x = self.moreButton.frame.origin.x-MENUBACKGROUND_WIDTH-5;
        [UIView beginAnimations:@"MenuBackgroundShow" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        menuBackgroundView.frame = frame;
        [UIView commitAnimations];
        menuBackgroundView.tag = 0;
    }
}

- (void)hideAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    [menuBackgroundView removeFromSuperview];
}

#pragma mark - Private

// 设置菜单
- (void)setupCategoryMenuView
{
    UIImage *dotIcon = [UIImage imageNamed:@"DotIcon"];
    mainMenuBackgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MENUBACKGROUND_WIDTH, MENU_ITEM_HEIGHT)];
    mainMenuBackgroundView.contentSize = CGSizeMake(MENU_ITEM_WIDTH*categoryDatas.count, MENU_ITEM_HEIGHT);
    [menuBackgroundView addSubview:mainMenuBackgroundView];
    int i = 1;
    for (NSDictionary *categoryData in categoryDatas) {
        UIButton *mainMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mainMenuButton.frame = CGRectMake(MENU_ITEM_WIDTH*(i-1), 0, MENU_ITEM_WIDTH, MENU_ITEM_HEIGHT);
        if (i == 1) {
            mainMenuButton.backgroundColor = [UIColor blackColor];
            currentMainMenuItem = mainMenuButton;
        } else {
            mainMenuButton.backgroundColor = [UIColor getColorWithHexValue:@"252730"];
        }
        NSNumber *typeID = [categoryData objectForKey:@"id"];
        mainMenuButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        mainMenuButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [mainMenuButton setTitle:[categoryData objectForKey:@"caption"] forState:UIControlStateNormal];
        [mainMenuButton addTarget:self action:@selector(mainMuneItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        mainMenuButton.showsTouchWhenHighlighted = YES;
        mainMenuButton.tag = -10*i;
        mainMenuButton.titleLabel.tag = typeID.integerValue;
        [mainMenuBackgroundView addSubview:mainMenuButton];
        //
        [self loadMainMenuItemIcon:[categoryData objectForKey:@"icon"] tag:mainMenuButton.tag];
        // 设置子菜单
        NSArray *subtypeDatas = [categoryData objectForKey:@"subtypes"];
        UIScrollView *submenuScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, MENU_ITEM_HEIGHT, MENUBACKGROUND_WIDTH, MENUBACKGROUND_HEIGHT-MENU_ITEM_HEIGHT)];
        NSInteger lineNumber = subtypeDatas.count/4;
        if (subtypeDatas.count%4 != 0) {
            lineNumber++;
        }
        submenuScrollView.contentSize = CGSizeMake(MENUBACKGROUND_WIDTH, MENU_ITEM_HEIGHT*lineNumber);
        submenuScrollView.backgroundColor = [UIColor blackColor];
        [menuBackgroundView addSubview:submenuScrollView];
        [submenuScrollViewArray addObject:submenuScrollView];
        CGFloat startX = 0;
        CGFloat startY = 0;
        int j = 0;
        for (NSDictionary *subtypeData in subtypeDatas) {
            UIButton *subMenuItem = [UIButton buttonWithType:UIButtonTypeCustom];
            subMenuItem.frame = CGRectMake(startX, startY, MENU_ITEM_WIDTH, MENU_ITEM_HEIGHT);
            subMenuItem.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            subMenuItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            subMenuItem.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            subMenuItem.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            subMenuItem.showsTouchWhenHighlighted = YES;
            NSNumber *subID = [subtypeData objectForKey:@"subtype_id"];
            subMenuItem.tag = j;
            subMenuItem.titleLabel.tag = subID.integerValue;
            [subMenuItem addTarget:self action:@selector(subMuneItemPressed:) forControlEvents:UIControlEventTouchUpInside];
            if ((i == 1) && (j == 0)) {
                [subMenuItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                currentSubMenuItem = subMenuItem;
            } else {
                [subMenuItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            [subMenuItem setTitle:[subtypeData objectForKey:@"sub_caption"] forState:UIControlStateNormal];
            [subMenuItem setImage:dotIcon forState:UIControlStateNormal];
            [submenuScrollView addSubview:subMenuItem];
            startX += MENU_ITEM_WIDTH;
            if (startX >= MENUBACKGROUND_WIDTH) {
                startX = 0;
                startY += MENU_ITEM_HEIGHT;
            }
            j++;
        }
        //
        i++;
    }
    //
    [self requstProductsFromServer:currentSubMenuItem.titleLabel.tag];
    //
    [menuBackgroundView bringSubviewToFront:[submenuScrollViewArray objectAtIndex:0]];
}

// 异步加载主菜单图标
- (void)loadMainMenuItemIcon:(NSString*)imageURL tag:(NSInteger)tag
{
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:imageURL];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tag], @"tag", nil];
        request.didFinishSelector = @selector(categoryIconRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        UIButton *button = (UIButton*)[mainMenuBackgroundView viewWithTag:tag];
        [button setImage:cachedImage forState:UIControlStateNormal];
    }
}

// 主菜单点击后要刷新背景及子菜单面板
- (void)mainMuneItemPressed:(id)sender
{
    UIButton *button = sender;
    if (button.tag != currentMainMenuItem.tag) {
        NSInteger index = button.tag/-10;
        currentMainMenuItem.backgroundColor = [UIColor getColorWithHexValue:@"252730"];
        button.backgroundColor = [UIColor blackColor];
        [menuBackgroundView bringSubviewToFront:[submenuScrollViewArray objectAtIndex:index-1]];
        currentMainMenuItem = button;
    }
}

// 子主菜单点击后要刷新导航条内容及收缩子菜单面板
- (void)subMuneItemPressed:(id)sender
{
    UIButton *button = sender;
    if (button.titleLabel.tag != currentSubMenuItem.titleLabel.tag) {
        [currentSubMenuItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        currentSubMenuItem = button;
        [self refreshPositionLabel];
        [self requstProductsFromServer:currentSubMenuItem.titleLabel.tag];
    }
    [self hideMenuBackgroundView];
}

// 刷新当前菜单位置
- (void)refreshPositionLabel
{
    NSInteger index = currentMainMenuItem.tag/-10-1;
    NSDictionary *categoryData = [categoryDatas objectAtIndex:index];
    NSString *caption = [categoryData objectForKey:@"caption"];
    NSArray *subcategoryDatas = [categoryData objectForKey:@"subtypes"];
    NSDictionary *subCategoryData = [subcategoryDatas objectAtIndex:currentSubMenuItem.tag];
    NSString *subcaption = [subCategoryData objectForKey:@"sub_caption"];
    NSString *positionText = [NSString stringWithFormat:@"%@ / %@", caption, subcaption];
    CGSize size = [positionText sizeWithFont:self.positionLabel.font];
    self.positionLabel.text = positionText;
    CGRect frame = self.positionLabel.frame;
    frame.size.width = size.width+20;
    frame.origin.x = self.moreButton.frame.origin.x-10-frame.size.width;
    self.positionLabel.frame = frame;
}

// 获取产品列表数据
- (void)requstProductsFromServer:(NSInteger)subtypeID
{
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    NSString *categoryURLStr = [NSString stringWithFormat:@"%@r=mydo/getsolutions&solution_subseries_id=%d&store_id=%@", HOST_DOMAIN, subtypeID, [userInfo objectForKey:@"store_id"]];
    NSLog(@"%@", categoryURLStr);
    NSURL *url = [NSURL URLWithString:categoryURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(productsDataRequestFinished:);
    [asiHttpRequest startSynchronous];
}

- (void)setupProductListView:(NSArray*)productDatas
{
    if (serviceListViewController) {
        [serviceListViewController cancelAllOperations];
        [serviceListViewController.view removeFromSuperview];
        serviceListViewController = nil;
    }
    NSArray *convertedDatas = [self getConvertedProductDataForList:productDatas];
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
        categoryDatas = [resultData objectForKey:@"types"];
        [self setupCategoryMenuView];
        [self refreshPositionLabel];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)productsDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupProductListView:[resultData objectForKey:@"services"]];
        [self setupPageIndexIndicator];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)categoryIconRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    NSNumber *tag = [request.userInfo objectForKey:@"tag"];
    UIButton *button = (UIButton*)[mainMenuBackgroundView viewWithTag:tag.integerValue];
    [button setImage:image forState:UIControlStateNormal];
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

#pragma mark - ServiceListCallBack Delegate

- (void)serviceListScrollCallBack:(NSInteger)pageIndex
{
    [pageIndexViewController moveTo:pageIndex];
    if (self.moreButton.tag == 1) {
        [self moreButtonPressed:self.moreButton];
    }
}

- (void)serviceListTouchCallBack:(NSInteger)serviceID
{
    if (self.moreButton.tag == 1) {
        [self moreButtonPressed:self.moreButton];
    }
    solutionDetailViewController = [[MSSolutionDetailViewController alloc]initWithNibName:@"MSSolutionDetailViewController" bundle:nil serviceID:serviceID];
    solutionDetailViewController.mainViewController = self.mainViewController;
    [self.mainViewController enterServiceDetailView:solutionDetailViewController selector:@selector(setupServiceInfoView)];
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
}
@end

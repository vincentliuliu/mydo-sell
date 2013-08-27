//
//  MSEnvironmentDetailViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 8/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSEnvironmentDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Constants.h"
#import "MSSystemUtils.h"
#import "MSWebImageCacher.h"
#import "UIColor+HexToRGBColor.h"
#import "MSMainViewController.h"
#import "MSPageIndexViewController.h"

@interface MSEnvironmentDetailViewController ()

@end

@implementation MSEnvironmentDetailViewController

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

- (void)setupServiceInfoView
{
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getstore&store_id=%d", HOST_DOMAIN, serviceID];
    NSLog(@"%@", solutionURLStr);
    NSURL *url = [NSURL URLWithString:solutionURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(storeDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)initStoreInfo:(NSDictionary*)storeData
{
    serviceData = storeData;
    imageURLs = [serviceData objectForKey:@"images"];
    self.storeTitle.text = [serviceData objectForKey:@"title"];
    self.storeSubtitle.text = [serviceData objectForKey:@"subtitle"];
    NSString *description = [serviceData objectForKey:@"description"];
    NSString *address = [serviceData objectForKey:@"address"];
    NSString *tel_number = [serviceData objectForKey:@"tel_number"];
    CGSize size = [description sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 9999)];
    CGRect frame = self.descriptionLabel.frame;
    frame.size.height = size.height;
    self.descriptionLabel.frame = frame;
    self.descriptionScrollView.contentSize = size;
    self.descriptionLabel.text = description;
    self.locationLabel.text = address;
    self.contactLabel.text = tel_number;
}

// 设置分页指示器
- (void)setupPageIndexIndicator
{
    pageIndexViewController = [[MSPageIndexViewController alloc]initWithNibName:@"MSPageIndexViewController" bundle:nil pageCount:imageURLs.count];
    CGRect frame = pageIndexViewController.view.frame;
    frame.origin.y = (self.pageIndicatorBackground.frame.size.height-frame.size.height)/2;
    frame.origin.x = (self.pageIndicatorBackground.frame.size.width-frame.size.width)/2;
    pageIndexViewController.view.frame = frame;
    [self.pageIndicatorBackground addSubview:pageIndexViewController.view];
}

- (void)initStoreImages
{
    CGFloat startX = 0;
    for (NSString *imageURL in imageURLs) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(startX, (self.storeImageScrollView.frame.size.height-30)/2, self.storeImageScrollView.frame.size.width, 30)];
        label.font = [UIFont boldSystemFontOfSize:30];
        label.text = @"正在加载图片...";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.storeImageScrollView addSubview:label];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(startX, 0, self.storeImageScrollView.frame.size.width, self.storeImageScrollView.frame.size.height)];
        imageView.backgroundColor = [UIColor clearColor];
        [self.storeImageScrollView addSubview:imageView];
        startX += self.storeImageScrollView.frame.size.width;
        [self loadStoreImage:imageURL imageView:imageView];
    }
    self.storeImageScrollView.contentSize = CGSizeMake(startX, self.storeImageScrollView.frame.size.height);
}

// 异步加载会所图片
- (void)loadStoreImage:(NSString*)imageURL imageView:(UIImageView*)imageView
{
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:imageURL];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"view", nil];
        request.didFinishSelector = @selector(storeImageRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        imageView.image = cachedImage;
    }
}

#pragma mark - ASIHttpRequest Delegate

- (void)storeDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self initStoreInfo:[resultData objectForKey:@"store_info"]];
        [self setupPageIndexIndicator];
        [self initStoreImages];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)storeImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    UIImageView *imageView = [request.userInfo objectForKey:@"view"];
    imageView.image = image;
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

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    if (pageIndex != currentPageIndex) {
        [pageIndexViewController moveTo:pageIndex];
        currentPageIndex = pageIndex;
    }
}

@end

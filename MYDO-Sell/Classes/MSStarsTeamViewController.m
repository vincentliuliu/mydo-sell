//
//  MSStarsTeamViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSStarsTeamViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MSShareDataCache.h"
#import "MSWebImageCacher.h"
#import "MSSystemUtils.h"
#import "MSPageIndexViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MSStarsTeamViewController ()

@end

@implementation MSStarsTeamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary *userInfo = [MSShareDataCache getUserInfo];
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getstaffs&store_id=%@", HOST_DOMAIN, [userInfo objectForKey:@"store_id"]];
    NSLog(@"%@", solutionURLStr);
    NSURL *url = [NSURL URLWithString:solutionURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(staffDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ASIHttpRequest Delegate

- (void)staffDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        staffDatas = [resultData objectForKey:@"staffs"];
        [self setupStaffListView];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)staffImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    UIImageView *imageview = [request.userInfo objectForKey:@"imageview"];
    imageview.image = image;
    [MSWebImageCacher cacheWebImage:request.url.description image:image];
}

#pragma mark - 构建显示界面

- (void)setupStaffListView
{
    CGFloat horizontalInterval = 45;
    CGFloat verticalInterval = 50;
    NSInteger colNumberInALine = 3;
    NSInteger rowNumberInAPage = 2;
    CGFloat staffBackgroundViewWidth = (self.contentScrollView.frame.size.width-horizontalInterval*(colNumberInALine+1))/colNumberInALine;
    CGFloat staffBackgroundViewHeight = (self.contentScrollView.frame.size.height-verticalInterval*(rowNumberInAPage-1))/rowNumberInAPage;
    CGFloat startX = horizontalInterval;
    CGFloat startY = 0;
    int colIndex = 1;
    int rowIndex = 1;
    int pageIndex = 1;
    for (NSDictionary *staffData in staffDatas) {
        UIView *view = [self getStaffView:staffData rect:CGRectMake(startX+(staffBackgroundViewWidth+horizontalInterval)*(colIndex-1), startY+(staffBackgroundViewHeight+verticalInterval)*(rowIndex-1), staffBackgroundViewWidth, staffBackgroundViewHeight)];
        [self.contentScrollView addSubview:view];
        colIndex++;
        if (colIndex%(colNumberInALine+1) == 0) {
            colIndex = 1;
            rowIndex++;
            if (rowIndex%(rowNumberInAPage+1) == 0) {
                startX += self.contentScrollView.frame.size.width;
                pageIndex++;
                rowIndex = 1;
            }
        }
    }
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width*pageIndex, self.contentScrollView.frame.size.height);
    [self setupPageIndexIndicator:pageIndex];
}

- (UIView*)getStaffView:(NSDictionary*)staffData rect:(CGRect)rect
{
    CGFloat imageWidth = 84;
    UIView *backgroundView = [[UIView alloc]initWithFrame:rect];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
    imageView.layer.cornerRadius = 42;
    imageView.layer.borderWidth = 2;
    imageView.layer.borderColor = [UIColor getColorWithHexValue:@"a7a9ac"].CGColor;
    imageView.layer.masksToBounds = YES;
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:[staffData objectForKey:@"avatar"]];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"imageview", nil];
        request.didFinishSelector = @selector(staffImageRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        imageView.image = cachedImage;
    }
    [backgroundView addSubview:imageView];
    UILabel *nicknameLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageWidth+20, 0, rect.size.width-imageWidth-20, imageWidth/2)];
    nicknameLabel.backgroundColor = [UIColor clearColor];
    nicknameLabel.numberOfLines = 1;
    nicknameLabel.font = [UIFont boldSystemFontOfSize:18];
    nicknameLabel.textColor = [UIColor getColorWithHexValue:@"838486"];
    nicknameLabel.text = [staffData objectForKey:@"nickname"];
    [backgroundView addSubview:nicknameLabel];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(nicknameLabel.frame.origin.x, imageWidth/2, nicknameLabel.frame.size.width-10, 1)];
    line.backgroundColor = [UIColor getColorWithHexValue:@"f5f5f5"];
    [backgroundView addSubview:line];
    UILabel *occupationLabel = [[UILabel alloc]initWithFrame:CGRectMake(nicknameLabel.frame.origin.x, nicknameLabel.frame.size.height+1, nicknameLabel.frame.size.width, nicknameLabel.frame.size.height-1)];
    occupationLabel.backgroundColor = [UIColor clearColor];
    occupationLabel.numberOfLines = 1;
    occupationLabel.font = [UIFont systemFontOfSize:18];
    occupationLabel.textColor = [UIColor getColorWithHexValue:@"c5c7c6"];
    occupationLabel.text = [staffData objectForKey:@"occupation"];
    [backgroundView addSubview:occupationLabel];
    NSString *description = [staffData objectForKey:@"description"];
    UIFont *font = [UIFont systemFontOfSize:16];
    CGFloat margin = 10;
    CGFloat maxWidth = rect.size.width-margin*2;
    CGFloat maxHeight = rect.size.height-imageWidth-margin;
    CGSize size = [description sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, 9999)];
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(margin, imageWidth+margin, maxWidth, size.height)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = font;
    descriptionLabel.textColor = [UIColor getColorWithHexValue:@"9b9c9e"];
    descriptionLabel.text = description;
    descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    if (size.height > maxHeight) {
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(margin, imageWidth+margin, maxWidth, maxHeight)];
        scrollView.contentSize = size;
        CGRect frame = descriptionLabel.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        descriptionLabel.frame = frame;
        [scrollView addSubview:descriptionLabel];
        [backgroundView addSubview:scrollView];
    } else {
        [backgroundView addSubview:descriptionLabel];
    }
    return backgroundView;
}

// 设置分页指示器
- (void)setupPageIndexIndicator:(NSInteger)pageCount
{
    pageIndexViewController = [[MSPageIndexViewController alloc]initWithNibName:@"MSPageIndexViewController" bundle:nil pageCount:pageCount];
    CGRect frame = pageIndexViewController.view.frame;
    frame.origin.y = PAGE_VIEW_CONTROLLER_FRAME_Y;
    frame.origin.x = (self.view.frame.size.width-frame.size.width)/2;
    pageIndexViewController.view.frame = frame;
    [self.view addSubview:pageIndexViewController.view];
}

- (void)removeFromMainView:(BOOL)animated
{
    [requestQueue cancelAllOperations];
    [super removeFromMainView:animated];
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

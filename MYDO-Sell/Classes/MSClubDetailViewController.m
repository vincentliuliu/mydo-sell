//
//  MSClubDetailViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSClubDetailViewController.h"
#import "MSShareDataCache.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "Constants.h"
#import "MSSystemUtils.h"
#import "MSWebImageCacher.h"
#import "UIColor+HexToRGBColor.h"

@interface MSClubDetailViewController ()

@end

@implementation MSClubDetailViewController

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
    self.descriptionLabel.textColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupServiceInfoView
{
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getsalon&salon_id=%d&store_id=%@", HOST_DOMAIN, serviceID, [[MSShareDataCache getUserInfo] objectForKey:@"store_id"]];
    NSLog(@"%@", solutionURLStr);
    NSURL *url = [NSURL URLWithString:solutionURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(salonDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)setupSalonInfoView:(NSDictionary*)salonInfo
{
    serviceData = salonInfo;
    self.titleLabel.text = [serviceData objectForKey:@"title"];
    self.subtitleLabel.text = [serviceData objectForKey:@"subtitle"];
    self.locationLabel.text = [serviceData objectForKey:@"address"];
    self.timeLabel.text = [serviceData objectForKey:@"date"];
    self.limitedNumberLabel.text = [NSString stringWithFormat:@"限定 %@ 人", [serviceData objectForKey:@"limited_number"]];
    NSString *description = [serviceData objectForKey:@"description"];
    CGSize size = [description sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(self.descriptionLabel.frame.size.width, 999)];
    CGRect frame = self.descriptionLabel.frame;
    frame.size = size;
    self.descriptionLabel.frame = frame;
    self.descriptionLabel.text = description;
}

- (void)loadPhotos:(NSArray*)photoURLs
{
    for (int i=-1; i>-5; i--) {
        UIImageView *imageView = (UIImageView*)[self.view viewWithTag:i];
        if (photoURLs.count >= i*-1) {
            NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:[photoURLs objectAtIndex:i*-1-1]];
            UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
            if (cachedImage == nil) {
                NSURL *url = [NSURL URLWithString:propertyImageURL];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.delegate = self;
                request.defaultResponseEncoding = NSUTF8StringEncoding;
                request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"view", nil];
                request.didFinishSelector = @selector(salonImageRequestFinished:);
                [requestQueue addOperation:request];
            } else {
                imageView.image = cachedImage;
            }
        } else {
            imageView.hidden = YES;
        }
    }
}

#pragma mark - ASIHttpRequest Delegate

- (void)salonDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        [self setupSalonInfoView:[resultData objectForKey:@"salon_info"]];
        [self loadPhotos:[serviceData objectForKey:@"photos"]];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)salonImageRequestFinished:(ASIHTTPRequest *)request
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

@end

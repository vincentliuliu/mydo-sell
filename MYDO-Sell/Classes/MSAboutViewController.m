//
//  MSAboutViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSAboutViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@interface MSAboutViewController ()

@end

@implementation MSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
        //
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 25.0f;
        paragraphStyle.maximumLineHeight = 25.0f;
        paragraphStyle.minimumLineHeight = 25.0f;
        attribute = @{NSParagraphStyleAttributeName : paragraphStyle,};
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self makeTheButtonSelected:self.responsibleButton];
    [self makeTheButtonUnselected:self.differenceButton];
    [self makeTheButtonUnselected:self.honorButton];
    //
    NSString *solutionURLStr = [NSString stringWithFormat:@"%@r=mydo/getabout", HOST_DOMAIN];
    NSLog(@"%@", solutionURLStr);
    NSURL *url = [NSURL URLWithString:solutionURLStr];
    asiHttpRequest = [ASIHTTPRequest requestWithURL:url];
    asiHttpRequest.delegate = self;
    asiHttpRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    asiHttpRequest.didFinishSelector = @selector(aboutDataRequestFinished:);
    //
    [asiHttpRequest startSynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)responsibleButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        [self makeTheButtonSelected:button];
        [self makeTheButtonUnselected:self.differenceButton];
        [self makeTheButtonUnselected:self.honorButton];
        button.tag = 1;
        self.differenceButton.tag = 0;
        self.honorButton.tag = 0;
        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:[aboutDataArray objectAtIndex:0] attributes:attribute];
    }
}

- (IBAction)differenceButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        [self makeTheButtonSelected:button];
        [self makeTheButtonUnselected:self.responsibleButton];
        [self makeTheButtonUnselected:self.honorButton];
        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:[aboutDataArray objectAtIndex:1] attributes:attribute];
    }
}

- (IBAction)honorButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        [self makeTheButtonSelected:button];
        [self makeTheButtonUnselected:self.differenceButton];
        [self makeTheButtonUnselected:self.responsibleButton];
        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:[aboutDataArray objectAtIndex:2] attributes:attribute];
    }
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

#pragma mark - ASIHttpRequest Delegate

- (void)aboutDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        aboutDataArray = [resultData objectForKey:@"about_info"];
        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:[aboutDataArray objectAtIndex:0] attributes:attribute];
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


@end

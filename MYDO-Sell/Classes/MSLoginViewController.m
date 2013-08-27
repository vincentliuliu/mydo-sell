//
//  MSLoginViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSLoginViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "MSRootViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "MSShareDataCache.h"

@interface MSLoginViewController (Private)

- (void)keyboardWillShow:(NSNotification*)aNotification;
- (void)keyboardWillHide:(NSNotification*)aNotification;

@end

@implementation MSLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.loginButton setImage:[UIImage imageNamed:@"LoginButton"] forState:UIControlStateNormal];
    [self.loginButton setImage:[UIImage imageNamed:@"LoginButtonSelected"] forState:UIControlStateHighlighted];
    isLocked = YES;
    loginPanelFrame = self.loginPanelView.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    if (isLocked) {
        BOOL flag = YES;
        if ((self.usernameTextField.text == nil) || (self.usernameTextField.text.length == 0)) {
            flag = NO;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:@"请输入用户名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ((self.passwordTextField.text == nil) || (self.passwordTextField.text.length == 0)) {
            flag = NO;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if (flag) {
            [self.usernameTextField resignFirstResponder];
            [self.passwordTextField resignFirstResponder];
            [self userAuthenticate:self.usernameTextField.text password:self.passwordTextField.text];
        }
    }
}

#pragma mark - Public

- (void)pullDown
{
    if (!isLocked) {
        [UIView beginAnimations:@"PullDown-1" context:nil];
        CGRect currentFrame = self.view.frame;
        currentFrame.origin.y = 0;
        self.view.frame = currentFrame;
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(lockAnimationDone1:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView commitAnimations];
    }
}

- (void)lockAnimationDone1:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    [UIView beginAnimations:@"PullDown-2" context:nil];
    CGRect currentFrame = self.view.frame;
    currentFrame.origin.y = -80;
    self.view.frame = currentFrame;
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(lockAnimationDone2:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

- (void)lockAnimationDone2:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    [UIView beginAnimations:@"PullDown-3" context:nil];
    CGRect currentFrame = self.view.frame;
    currentFrame.origin.y = 0;
    self.view.frame = currentFrame;
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
    isLocked = YES;
}

#pragma mark - Private

- (void)userAuthenticate:(NSString*)username password:(NSString*)password
{
    NSString *urlStr = [NSString stringWithFormat:@"%@r=mydo/login&username=%@&password=%@",HOST_DOMAIN, username, password];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request startSynchronous];
}

- (void)raiseUp
{
    self.usernameTextField.enabled = NO;
    self.passwordTextField.text = nil;
    [self.rootViewController performSelector:@selector(unlockSystem)];
    [UIView beginAnimations:@"Disappear" context:nil];
    CGRect currentFrame = self.view.frame;
    currentFrame.origin.y = -currentFrame.size.height;
    self.view.frame = currentFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDidStopSelector:@selector(lockAnimationDone:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];
}

- (void)lockAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    isLocked = NO;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    if (keyboardSize.height > keyboardSize.width) {
        keyboardSize.height = keyboardSize.width;
    }
    CGRect frame = self.loginPanelView.frame;
    frame.origin.y = self.view.frame.size.height - keyboardSize.height - frame.size.height;
    [UIView beginAnimations:@"KeyboardShow" context:nil];
    [UIView setAnimationDuration:0.3];
    self.loginPanelView.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [UIView beginAnimations:@"KeyboardHide" context:nil];
    [UIView setAnimationDuration:0.3];
    self.loginPanelView.frame = loginPanelFrame;
    [UIView commitAnimations];
}

#pragma mark - ASIHttpRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        if ([MSShareDataCache getUserInfo] == nil) {
            [MSShareDataCache setUserInfo:[resultData objectForKey:@"user_info"]];
            [self.rootViewController performSelector:@selector(loadMainViewController)];
        }
        [self raiseUp];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"登陆失败" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"数据下载失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)usernameFieldEnterPressed:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}
@end

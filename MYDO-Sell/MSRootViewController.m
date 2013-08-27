//
//  MSRootViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSRootViewController.h"
#import "MSLoginViewController.h"
#import "MSMainViewController.h"

@interface MSRootViewController ()

@end

@implementation MSRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    loginViewController = [[MSLoginViewController alloc]initWithNibName:@"MSLoginViewController" bundle:nil];
    loginViewController.rootViewController = self;
    [self.view addSubview:loginViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Public

- (void)loadMainViewController
{
    if (mainViewController == nil) {
        mainViewController = [[MSMainViewController alloc]initWithNibName:@"MSMainViewController" bundle:nil];
        mainViewController.rootViewController = self;
    }   
    [self.view insertSubview:mainViewController.view belowSubview:loginViewController.view];
}

- (void)lockSystem
{
    [self.view addSubview:loginViewController.view];
    [loginViewController pullDown];
}

- (void)unlockSystem
{
    mainViewController.lockSlider.value = mainViewController.lockSlider.maximumValue;
}

@end

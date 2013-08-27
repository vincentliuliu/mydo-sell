//
//  MSSecondLevelViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"
#import "MSMainViewController.h"
#import "Constants.h"

@interface MSSecondLevelViewController ()

@end

@implementation MSSecondLevelViewController

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
	// Do any additional setup after loading the view.
    self.view.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView beginAnimations:@"EnterSecondLevelView" context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(addAnimationDone:finished:context:)];
    self.view.alpha = 1;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeFromMainView:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"RemoveSecondLevelView" context:nil];
        [UIView setAnimationDuration:0.7    ];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(removeAnimationDone:finished:context:)];
        self.view.alpha = 0;
        [UIView commitAnimations];
    } else {
        [self.view removeFromSuperview];
        [self removeAnimationDone:@"RemoveSecondLevelView" finished:YES context:nil];
    }
}

- (void)removeAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    [self.view removeFromSuperview];
    if ((self.mainViewCallbackSelector) && ([self.mainViewController respondsToSelector:self.mainViewCallbackSelector])) {
        [self.mainViewController performSelector:self.mainViewCallbackSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:SECONDACTION_VIEW_REMOVE, MAINVIEW_CALLBACK_ACTION_TYPE, nil]];
    }
}

- (void)addAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    if ((self.mainViewCallbackSelector) && ([self.mainViewController respondsToSelector:self.mainViewCallbackSelector])) {
        [self.mainViewController performSelector:self.mainViewCallbackSelector withObject:[NSDictionary dictionaryWithObjectsAndKeys:SECONDACTION_VIEW_EXCHANGE, MAINVIEW_CALLBACK_ACTION_TYPE, nil]];
    }
}

- (void)sendANotice:(NSDictionary*)data
{
    // something you may do here ...
}

@end

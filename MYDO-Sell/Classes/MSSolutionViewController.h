//
//  MSSolutionViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"
#import "MSServiceListCallBackDelegate.h"

@class MSPageIndexViewController;
@class ASIHTTPRequest;
@class MSServiceListViewController;
@class MSSolutionDetailViewController;

@interface MSSolutionViewController : MSSecondLevelViewController <MSServiceListCallBackDelegate>
{
    UIView *menuBackgroundView;
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    UIScrollView *mainMenuBackgroundView;
    NSMutableArray *submenuScrollViewArray;
    UIButton *currentMainMenuItem, *currentSubMenuItem;
    NSArray *categoryDatas;
    MSServiceListViewController *serviceListViewController;
    MSPageIndexViewController *pageIndexViewController;
    MSSolutionDetailViewController *solutionDetailViewController;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *positionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *moreButton;

- (IBAction)moreButtonPressed:(id)sender;

@end

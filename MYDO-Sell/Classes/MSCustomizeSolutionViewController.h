//
//  MSCustomizeSolutionViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"
#import "MSServiceListCallBackDelegate.h"

@class ASIHTTPRequest;
@class MSServiceListViewController;
@class MSPageIndexViewController;
@class MSCustomizeSolutionDetailViewController;

@interface MSCustomizeSolutionViewController : MSSecondLevelViewController <MSServiceListCallBackDelegate>
{
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    NSMutableArray *menuButtons;
    MSServiceListViewController *serviceListViewController;
    MSPageIndexViewController *pageIndexViewController;
    MSCustomizeSolutionDetailViewController *customizeSolutionDetailViewController;
}

@end

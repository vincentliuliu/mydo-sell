//
//  MSEnvironmentViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"
#import "MSServiceListCallBackDelegate.h"

@class ASIHTTPRequest;
@class MSServiceListViewController;
@class MSEnvironmentDetailViewController;
@class MSPageIndexViewController;

@interface MSEnvironmentViewController : MSSecondLevelViewController <MSServiceListCallBackDelegate>
{
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    MSServiceListViewController *serviceListViewController;
    MSEnvironmentDetailViewController *enviromentDetailViewController;
    MSPageIndexViewController *pageIndexViewController;
}

@end

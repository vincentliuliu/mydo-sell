//
//  MSClubViewController.h
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
@class MSClubDetailViewController;

@interface MSClubViewController : MSSecondLevelViewController <MSServiceListCallBackDelegate>
{
    UIImage *locationIcon, *timeIcon;
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    NSArray *currentConvertedSalonDatas, *expiredSalonConvertedDatas;
    MSServiceListViewController *serviceListViewController;
    MSPageIndexViewController *pageIndexViewController;
    MSClubDetailViewController *clubDetailViewController;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *currentSlansButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *expiredSalonsButton;

- (IBAction)currentSalonsButtonPressed:(id)sender;
- (IBAction)expiredSalonsButtonPressed:(id)sender;

@end

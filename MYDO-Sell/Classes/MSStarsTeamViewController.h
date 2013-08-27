//
//  MSStarsTeamViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"

@class ASIHTTPRequest;
@class MSPageIndexViewController;

@interface MSStarsTeamViewController : MSSecondLevelViewController <UIScrollViewDelegate>
{
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    NSArray *staffDatas;
    MSPageIndexViewController *pageIndexViewController;
    NSInteger currentPageIndex;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *contentScrollView;

@end

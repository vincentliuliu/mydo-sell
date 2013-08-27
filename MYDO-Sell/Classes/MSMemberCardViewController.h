//
//  MSMemberCardViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSecondLevelViewController.h"

@class MSPageIndexViewController;
@class ASIHTTPRequest;

@interface MSMemberCardViewController : MSSecondLevelViewController <UIScrollViewDelegate>
{
    NSArray *cardDatas;
    NSInteger currentPageIndex;
    NSMutableArray *cardImageViews, *cardPriceList;
    MSPageIndexViewController *pageIndexViewController;
    UIImage *cardShadowImage, *linesBackgroundImage, *defaultVipCardImage;
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *cardInfoScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *cardImageScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shopButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *orderedNumberLabel;

- (IBAction)shopButtonPressed:(id)sender;

@end

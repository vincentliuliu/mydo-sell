//
//  MSEnvironmentDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 8/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceDetailViewController.h"

@class MSPageIndexViewController;

@interface MSEnvironmentDetailViewController : MSServiceDetailViewController <UIScrollViewDelegate>
{
    MSPageIndexViewController *pageIndexViewController;
    NSArray *imageURLs;
    NSInteger currentPageIndex;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *pageIndicatorBackground;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *storeTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *storeSubtitle;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *descriptionScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *storeImageScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contactLabel;

@end

//
//  MSServiceListViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceListCallBackDelegate.h"

@interface MSServiceListViewController : UIViewController <UIScrollViewDelegate>
{
    NSOperationQueue *requestQueue;
    NSMutableArray *itemMaxHeightArray;
    NSInteger currentPageIndex;
}

@property (strong, nonatomic) NSArray *serviceDatas;
@property (assign, nonatomic) BOOL *canNotBePressed;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *servicesScrollView;
@property (strong, nonatomic) id<MSServiceListCallBackDelegate> callbackDelegate;
@property (readonly, nonatomic)NSInteger pageCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil serviceDatas:(NSArray*)serviceDatas;
- (void)loadServiceImages;
- (void)cancelAllOperations;
@end
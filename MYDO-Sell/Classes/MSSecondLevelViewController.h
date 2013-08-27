//
//  MSSecondLevelViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/4/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSMainViewController;

@interface MSSecondLevelViewController : UIViewController

@property (strong, nonatomic) MSMainViewController *mainViewController;
@property (assign, nonatomic) SEL mainViewCallbackSelector;

- (void)removeFromMainView:(BOOL)animated;
- (void)sendANotice:(NSDictionary*)data;

@end

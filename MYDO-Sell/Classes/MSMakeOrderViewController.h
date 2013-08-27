//
//  MSMakeOrderViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/22/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSMainViewController;

@interface MSMakeOrderViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *OrderButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *orderedItemTableView;
@property (unsafe_unretained, nonatomic) IBOutlet MSMainViewController *mainViewController;

- (IBAction)makeOrderButtonPressed:(id)sender;

@end

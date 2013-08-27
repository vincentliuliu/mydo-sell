//
//  MSServiceDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;
@class MSMainViewController;

@interface MSServiceDetailViewController : UIViewController
{
    NSInteger serviceID;
    NSDictionary *serviceData;
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;
@property (unsafe_unretained, nonatomic) MSMainViewController *mainViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil serviceID:(NSInteger)theServiceID;
- (void)setupServiceInfoView;
- (IBAction)backButtonPressed:(id)sender;

@end

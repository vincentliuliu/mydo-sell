//
//  MSLoginViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class MSRootViewController;

@interface MSLoginViewController : UIViewController
{
    BOOL isLocked;
    CGRect loginPanelFrame;
}

@property (strong, nonatomic) MSRootViewController *rootViewController;
@property (unsafe_unretained, nonatomic)IBOutlet UIView *loginPanelView;
@property (unsafe_unretained, nonatomic)IBOutlet UIButton *loginButton;
@property (unsafe_unretained, nonatomic)IBOutlet UITextField *usernameTextField;
@property (unsafe_unretained, nonatomic)IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)usernameFieldEnterPressed:(id)sender;
- (void)pullDown;

@end

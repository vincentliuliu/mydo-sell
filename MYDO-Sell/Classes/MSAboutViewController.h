//
//  MSAboutViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSecondLevelViewController.h"

@class ASIHTTPRequest;

@interface MSAboutViewController : MSSecondLevelViewController
{
    ASIHTTPRequest *asiHttpRequest;
    NSOperationQueue *requestQueue;
    NSArray *aboutDataArray;
    NSDictionary *attribute;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *responsibleButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *differenceButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *honorButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)responsibleButtonPressed:(id)sender;
- (IBAction)differenceButtonPressed:(id)sender;
- (IBAction)honorButtonPressed:(id)sender;

@end

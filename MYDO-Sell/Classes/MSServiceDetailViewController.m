//
//  MSServiceDetailViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSServiceDetailViewController.h"
#import "MSMainViewController.h"

@interface MSServiceDetailViewController ()

@end

@implementation MSServiceDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil serviceID:(NSInteger)theServiceID
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        serviceID = theServiceID;
        //
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.backButton setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [requestQueue cancelAllOperations];
    [self.mainViewController removeServiceDetailView];
}

- (void)setupServiceInfoView
{
    
}

@end

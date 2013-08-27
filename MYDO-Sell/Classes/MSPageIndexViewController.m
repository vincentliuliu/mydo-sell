//
//  MSPageIndexViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/21/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSPageIndexViewController.h"
#import "UIColor+HexToRGBColor.h"

@interface MSPageIndexViewController ()

@end

@implementation MSPageIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageCount:(NSInteger)pageCount
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self countStepSize:pageCount];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.pageIndexLabel.backgroundColor = [UIColor getColorWithHexValue:@"fbc779"];
    UIImage *pageIndexLineImage = [UIImage imageNamed:@"PageIndexLine"];
    pageIndexLineImage = [pageIndexLineImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    self.pageLineImageView.image = pageIndexLineImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)moveTo:(NSInteger)pageIndex
{
    CGRect frame = self.pageIndexLabel.frame;
    frame.origin.x = moveStep*pageIndex;
    [UIView beginAnimations:@"PageIndicator" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.pageIndexLabel.frame = frame;
    self.pageIndexLabel.text = [NSString stringWithFormat:@"%d", pageIndex+1];
    [UIView commitAnimations];
}

- (void)resetPageCount:(NSInteger)pageCount
{
    [self countStepSize:pageCount];
    [self moveTo:0];
}

- (void)countStepSize:(NSInteger)pageCount
{
    stepTotalCount = pageCount;
    if (stepTotalCount > 1) {
        moveStep = (self.view.frame.size.width-8-self.pageIndexLabel.frame.size.width)/(pageCount-1);
    } else {
        moveStep = 0;
    }
}

@end

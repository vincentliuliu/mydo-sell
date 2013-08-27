//
//  MSSolutionDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/29/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceDetailViewController.h"

@interface MSSolutionDetailViewController : MSServiceDetailViewController
{
    UIButton *shopButton, *operationFlowButton;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *operationFlowView;
@property (unsafe_unretained, nonatomic) BOOL shoppingIsNotAllowed;

@end

//
//  MSCustomizeSolutionDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceDetailViewController.h"

@interface MSCustomizeSolutionDetailViewController : MSServiceDetailViewController
{
    UIButton *shopButton, *componentsButton;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *infoScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *componentsView;

@end

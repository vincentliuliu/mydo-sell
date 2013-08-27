//
//  MSRecommendedProductDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 8/8/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceDetailViewController.h"

@interface MSRecommendedProductDetailViewController : MSServiceDetailViewController
{
    UIButton *shopButton;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *infoScrollView;

@end

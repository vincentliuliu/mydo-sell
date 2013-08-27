//
//  MSClubDetailViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 8/6/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSServiceDetailViewController.h"

@interface MSClubDetailViewController : MSServiceDetailViewController

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *timeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *limitedNumberLabel;


@end

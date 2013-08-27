//
//  MSShopBagListCell.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/25/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSShopBagListCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *itemImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *deleteButton;

@end

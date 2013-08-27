//
//  MSShoppedItemData.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/21/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSShoppedItemData : NSObject

// 1-会员卡 2-普通产品 3-精品 4-定制方案
@property (assign,nonatomic) NSInteger *type;
@property (assign,nonatomic) NSInteger *itemID;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSString *name;
@property (assign,nonatomic) CGFloat price;
@property (assign,nonatomic) CGFloat priceForVIP;

- (id)init;

@end

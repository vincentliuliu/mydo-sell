//
//  MSServiceData.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/29/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSStateItemData;

@interface MSServiceData : NSObject

@property (assign, nonatomic) NSInteger serviceID;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSArray *stateItems;

- (id)initWithServiceID:(NSInteger)serviceID imageURL:(NSString*)imageURL stateItems:(NSArray*)stateItems;

@end

@interface MSStateItemData : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIImage *icon;
@property (assign, nonatomic) CGFloat topSpace;
@property (assign, nonatomic) CGSize finalSize;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (assign, nonatomic) BOOL singleLine;

- (id)initWithTitle:(NSString*)title font:(UIFont*)font color:(UIColor*)color icon:(UIImage*)icon topSpace:(CGFloat)topSpace textAlignment:(NSTextAlignment)textAlignment singleLine:(BOOL)singleLine;

@end

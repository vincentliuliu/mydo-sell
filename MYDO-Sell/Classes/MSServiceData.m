//
//  MSServiceData.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/29/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSServiceData.h"

@implementation MSServiceData

- (id)initWithServiceID:(NSInteger)serviceID imageURL:(NSString*)imageURL stateItems:(NSArray*)stateItems
{
    self = [super init];
    if (self) {
        self.serviceID = serviceID;
        self.imageURL = imageURL;
        self.stateItems = stateItems;
    }
    return self;
}

@end

@implementation MSStateItemData

- (id)initWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color icon:(UIImage *)icon topSpace:(CGFloat)topSpace textAlignment:(NSTextAlignment)textAlignment singleLine:(BOOL)singleLine
{
    self = [super init];
    if (self) {
        self.title = title;
        self.font = font;
        self.color = color;
        self.icon = icon;
        self.topSpace = topSpace;
        self.textAlignment = textAlignment;
        self.singleLine = singleLine;
    }
    return self;
}

@end

//
//  UIColor+HexToRGBColor.h
//  miyue
//
//  Created by vincent liu on 3/27/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexToRGBColor)

+ (UIColor*)getColorWithHexValue:(NSString*)hexColor;
+ (UIImage*)createImageWithColor:(UIColor*)color;

@end

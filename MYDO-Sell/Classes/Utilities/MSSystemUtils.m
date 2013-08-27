//
//  MSSystemUtils.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/20/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSSystemUtils.h"

@implementation MSSystemUtils

+ (BOOL)isRetinaDisplay
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*)getPropertyImageURL:(NSString*)imageURL
{
    if ([self isRetinaDisplay]) {
        NSRange range = [imageURL rangeOfString:@"." options:NSBackwardsSearch];
        NSString *suffix = [imageURL substringFromIndex:range.location];
        NSString *url = [imageURL substringToIndex:range.location];
        return [NSString stringWithFormat:@"%@_2x%@", url, suffix];
    } else {
        return imageURL;
    }
}

@end

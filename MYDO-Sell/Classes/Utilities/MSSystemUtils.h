//
//  MSSystemUtils.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/20/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSystemUtils : NSObject

+ (BOOL)isRetinaDisplay;
+ (NSString*)getPropertyImageURL:(NSString*)imageURL;
@end

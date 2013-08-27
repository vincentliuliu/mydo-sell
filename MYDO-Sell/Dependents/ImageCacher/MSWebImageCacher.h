//
//  MSWebImageCacher.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSWebImageCacher : NSObject

+ (void)loadCacheItemsIndex;
+ (UIImage*)getCacheImage:(NSString*)url;
+ (NSString*)cacheWebImage:(NSString*)url image:(UIImage*)image;

@end

//
//  MSFileHelper.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSFileHelper : NSObject

+ (NSString*)pathInDocumentDirectory:(NSString*)fileName;
+ (NSString*)pathInCacheDirectory:(NSString*)fileName;
+ (NSString*)hashPathNameForURL:(NSString*)url;
+ (NSString*)hashNameForURL:(NSString*)url;
@end

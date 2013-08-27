//
//  MSFileHelper.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSFileHelper.h"

@implementation MSFileHelper

+ (NSString*)pathInDocumentDirectory:(NSString*)fileName
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString*)pathInCacheDirectory:(NSString*)fileName
{
    //获取沙盒中缓存文件目录
    NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory=[cacheDirectories objectAtIndex:0];
    //将传入的文件名加在目录路径后面并返回
    return [cacheDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString*)hashPathNameForURL:(NSString*)url
{
    NSString *filename = [self hashNameForURL:url];
    return [self pathInCacheDirectory:filename];
}

+ (NSString*)hashNameForURL:(NSString*)url
{
    NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
    NSString *suffix = [url substringFromIndex:range.location];
    return [NSString stringWithFormat:@"MYDO_SELL_%u%@", [url hash], suffix];
}

@end

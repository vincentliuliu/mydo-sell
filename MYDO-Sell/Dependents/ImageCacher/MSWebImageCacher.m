//
//  MSWebImageCacher.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSWebImageCacher.h"
#import "MSFileHelper.h"

#define CACHE_ITEMS_INDEX_FILE_NAME @"cache_items_index.dat"
#define MAX_CACHE_ITEM_COUNT 100
#define ORIGINAL_URL @"ORIGINAL_URL"
#define HASH_CACHE_FILENAME @"HASH_CACHE_FILENAME"

@implementation MSWebImageCacher

static NSMutableArray *cacheItemsIndex;

+ (void)loadCacheItemsIndex
{
    if (cacheItemsIndex == nil) {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSString *filePathName = [MSFileHelper pathInDocumentDirectory:CACHE_ITEMS_INDEX_FILE_NAME];
        if ([fileManager fileExistsAtPath:filePathName]) {
            cacheItemsIndex = [NSMutableArray arrayWithContentsOfFile:filePathName];
            for (NSDictionary *data in cacheItemsIndex) {
                NSLog(@"%@-%@",[data objectForKey:ORIGINAL_URL], [data objectForKey:HASH_CACHE_FILENAME]);
            }
        } else {
            cacheItemsIndex = [NSMutableArray array];
        }
    }
}

+ (UIImage*)getCacheImage:(NSString*)url{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    for (int i=cacheItemsIndex.count; i>0; i--) {
        NSDictionary *cacheItemData = [cacheItemsIndex objectAtIndex:i-1];
        NSString *originalURL = [cacheItemData objectForKey:ORIGINAL_URL];
        if ([originalURL isEqualToString:url]) {
            NSString *cacheFilename = [cacheItemData objectForKey:HASH_CACHE_FILENAME];
            if ([fileManager fileExistsAtPath:cacheFilename]) {
                NSData *imageData = [NSData dataWithContentsOfFile:cacheFilename];
                [cacheItemsIndex removeObjectAtIndex:i-1];
                [cacheItemsIndex addObject:cacheItemData];
                return [UIImage imageWithData:imageData];
            }
        }
    }
    return nil;
}

+ (NSString*)cacheWebImage:(NSString*)url image:(UIImage*)image
{
    NSString *hashPathName = [MSFileHelper hashPathNameForURL:url];
    // 存储文件
    NSData *imageData = [self imageToData:image url:url];
    [imageData writeToFile:hashPathName atomically:YES];
    // 记录索引表
    NSDictionary *cacheItemData = [NSDictionary dictionaryWithObjectsAndKeys: url, ORIGINAL_URL, hashPathName, HASH_CACHE_FILENAME, nil];
    [cacheItemsIndex addObject:cacheItemData];
    NSString *filePathName = [MSFileHelper pathInDocumentDirectory:CACHE_ITEMS_INDEX_FILE_NAME];
    [cacheItemsIndex writeToFile:filePathName atomically:YES];
    //
    [self releaseUselessCacheFile];
    return hashPathName;
}

+ (NSData*)imageToData:(UIImage*)image url:(NSString*)url
{
    NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
    NSString *suffix = [url substringFromIndex:range.location].lowercaseString;
    if ([suffix isEqualToString:@".png"]) {
        return UIImagePNGRepresentation(image);
    } else {
        return UIImageJPEGRepresentation(image, 1.0);
    }
}

+ (void)releaseUselessCacheFile
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    for (int i=cacheItemsIndex.count-MAX_CACHE_ITEM_COUNT-1; i>-1; i--) {
        NSDictionary *cacheItemData = [cacheItemsIndex objectAtIndex:i];
        NSString *cacheFilename = [cacheItemData objectForKey:HASH_CACHE_FILENAME];
        if (([fileManager fileExistsAtPath:cacheFilename])) {
            [fileManager removeItemAtPath:cacheFilename error:nil];
        }
        [cacheItemsIndex removeObjectAtIndex:i];
    }
}

@end

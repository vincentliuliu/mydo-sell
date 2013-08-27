//
//  MSShareDataCache.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/2/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSShareDataCache.h"
#import "MSShoppedItemData.h"

static NSDictionary *userInfoCache;
static NSMutableArray *itemsCache;

@implementation MSShareDataCache

+ (void)setUserInfo:(NSDictionary*)userInfo
{
    userInfoCache = userInfo;
}

+ (NSDictionary*)getUserInfo
{
    return userInfoCache;
}

+ (void)addItemToBag:(MSShoppedItemData*)productData
{
    if (itemsCache == nil) {
        itemsCache = [NSMutableArray array];
    }
    [itemsCache addObject:productData];
}

+ (NSArray*)itemsInShopBag
{
    return [NSArray arrayWithArray:itemsCache];
}

+ (void)removeItemFromBag:(id)itemData
{
    [itemsCache removeObject:itemData];
}

+ (void)clearItems
{
    [itemsCache removeAllObjects];
}

@end

//
//  MSShareDataCache.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/2/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSShoppedItemData;

@interface MSShareDataCache : NSObject

+ (void)setUserInfo:(NSDictionary*)userInfo;
+ (NSDictionary*)getUserInfo;
+ (void)addItemToBag:(MSShoppedItemData*)productData;
+ (NSArray*)itemsInShopBag;
+ (void)removeItemFromBag:(id)itemData;
+ (void)clearItems;

@end

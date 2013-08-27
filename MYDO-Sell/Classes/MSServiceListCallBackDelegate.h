//
//  MSServiceListCallBackDelegate.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/29/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSServiceListCallBackDelegate <NSObject>

@optional
- (void)serviceListScrollCallBack:(NSInteger)pageIndex;
- (void)serviceListTouchCallBack:(NSInteger)serviceID;

@end
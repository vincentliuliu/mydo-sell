//
//  MSServiceInfoPrintUtil.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/30/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSServiceInfoPrintUtil : NSObject

+ (CGFloat)drawServiceInfoInView:(UIView*)canvasView point:(CGPoint)point items:(NSArray*)items interval:(CGFloat)interval;
+ (CGFloat)drawServiceInfoInViewWithNoPrice:(UIView*)canvasView point:(CGPoint)point items:(NSArray*)items interval:(CGFloat)interval;
@end

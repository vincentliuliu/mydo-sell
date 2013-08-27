//
//  UIImage+ScaleAndCropping.m
//  miyue
//
//  Created by vincent liu on 5/30/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "UIImage+ScaleAndCropping.h"

@implementation UIImage (ScaleAndCropping)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    UIImage *sourceImage = (UIImage*)self;      
    CGSize imageSize = sourceImage.size;
    CGFloat sourceWidth = imageSize.width;
    CGFloat sourceHeight = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight; 
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / sourceWidth;//宽度缩放比例
        CGFloat heightFactor = targetHeight / sourceHeight;//高度缩放比例
        //按最大比例缩放
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = sourceWidth * scaleFactor;//缩放后宽度
        scaledHeight = sourceHeight * scaleFactor;//缩放后高度
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end

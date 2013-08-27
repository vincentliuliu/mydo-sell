//
//  MSMainViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

@class MSRootViewController;
@class MSSecondLevelViewController;
@class MSShoppedItemData;
@class MSMakeOrderViewController;

@interface MSMainViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray *productInfoDatas, *originalImages, *convertedImages, *sliderViews, *serviceDetailViewControllers;
    CGFloat fixedHideWidth;
    NSInteger startImageViewIndex, maxImageViewIndex, maxImageViewCount, recommendedImageCount;
    BOOL scrollLeftToRight;
    MSSecondLevelViewController *secondLevelViewController, *lastSecondLevelViewController;
    NSArray *secondLevelViewControllerNames;
    UIButton *lastMainMenuItemButton;
    UIImageView *selectedFlagImageView;
    MSMakeOrderViewController *makeOrderViewController;
    UIControl *hiddenController;
    BOOL menuItemCanPress;
    NSOperationQueue *requestQueue;
}

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;
@property (readwrite)	CFURLRef		lockSoundFileURLRef;
@property (readonly)	SystemSoundID	lockSoundFileObject;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *lockBackgroundImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *menuImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *recommendedServiceScorllView;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *lockSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *occupationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *userInfoView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *leftMenuView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *shopBagTipView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *countTipLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shopBagButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *shopbagBackgroundView;
@property (strong, nonatomic) MSRootViewController *rootViewController;

- (IBAction)sliderTouchUpIn:(id)sender;
- (void)addToShopBag:(MSShoppedItemData*)productData position:(CGPoint)position;
- (IBAction)shopBagButtonPressed:(id)sender;
- (void)hideControllerPressed:(id)sender;
- (void)secondViewCallBack:(NSDictionary*)data;
- (void)enterServiceDetailView:(UIViewController*)detailViewController selector:(SEL)selector;
- (void)removeServiceDetailView;

@end

//
//  MSMainViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSMainViewController.h"
#import "MSRootViewController.h"
#import "UIColor+HexToRGBColor.h"
#import "MSShareDataCache.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "UIImage+Convert.h"
#import "MSMemberCardViewController.h"
#import "MSSecondLevelViewController.h"
#import "MSShareDataCache.h"
#import "MSSystemUtils.h"
#import "MSShoppedItemData.h"
#import "MSMakeOrderViewController.h"
#import "Constants.h"
#import "MSWebImageCacher.h"
#import "MSCustomizeSolutionDetailViewController.h"
#import "MSEnvironmentDetailViewController.h"
#import "MSSolutionDetailViewController.h"
#import "MSRecommendedProductDetailViewController.h"
#import <AVFoundation/AVFoundation.h>

#define WIDTH_OF_IMAGE 270
#define HEIGHT_OF_IMAGE 530
#define ADDITIONAL_IMAGE_COUNT 3
#define LIGHTED_VIEW_OFFSET 2
#define MENUITEM_NAME @"MenuItem"
#define SELECTED_MENUITEM_NAME @"MenuItemSelected"
#define MENUITEM_HEIGHT 33
#define MENUITEM_INTERVAL 12

@interface MSMainViewController ()

@end

@implementation MSMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        secondLevelViewControllerNames = [NSArray arrayWithObjects:@"MSMemberCardViewController", @"MSSolutionViewController", @"MSRecommendedProductViewController", @"MSEnvironmentViewController", @"MSClubViewController", @"MSCustomizeSolutionViewController", @"MSStarsTeamViewController", @"MSAboutViewController", nil];
        menuItemCanPress = YES;
        serviceDetailViewControllers = [NSMutableArray array];
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
        //
        NSURL *scrollSound   = [[NSBundle mainBundle] URLForResource: @"tap"
                                                    withExtension: @"aif"];
        NSURL *lockSound   = [[NSBundle mainBundle] URLForResource: @"shutter"
                                                    withExtension: @"wav"];
        
        // Store the URL as a CFURLRef instance
        self.soundFileURLRef = (CFURLRef) CFBridgingRetain(scrollSound);
        self.lockSoundFileURLRef = (CFURLRef) CFBridgingRetain(lockSound);
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID (
                                          _soundFileURLRef,
                                          &_soundFileObject
                                          );
        AudioServicesCreateSystemSoundID (
                                          _lockSoundFileURLRef,
                                          &_lockSoundFileObject
                                          );
        // 添加遮罩层
        hiddenController = [[UIControl alloc]initWithFrame:self.view.frame];
        hiddenController.backgroundColor = [UIColor blackColor];
        hiddenController.alpha = 0.5;
        [hiddenController addTarget:self action:@selector(hideControllerPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.leftMenuView.backgroundColor = [UIColor getColorWithHexValue:@"3db2c3"];
    self.userInfoView.backgroundColor = [UIColor getColorWithHexValue:@"39aaba"];
    UIImage *lockBackground = [UIImage imageNamed:@"LockBackground"];
    lockBackground = [lockBackground stretchableImageWithLeftCapWidth:lockBackground.size.width/2 topCapHeight:0];
    self.lockBackgroundImageView.image = lockBackground;
    UIImage *sliderBackground = [UIImage imageNamed:@"SliderBackground"];
    sliderBackground = [sliderBackground stretchableImageWithLeftCapWidth:sliderBackground.size.width/2 topCapHeight:0];
    [self.lockSlider setMinimumTrackImage:[UIColor createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.lockSlider setMaximumTrackImage:[UIColor createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.lockSlider setThumbImage:[UIImage imageNamed:@"LockButton"] forState:UIControlStateNormal];
    //
    [self setMainMenu:9];
    //
    [self.shopBagButton setBackgroundImage:[UIImage imageNamed:@"ShopBag"] forState:UIControlStateNormal];
    [self.shopBagButton setBackgroundImage:[UIImage imageNamed:@"ShopBagSelected"] forState:UIControlStateHighlighted];
    NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:[[MSShareDataCache getUserInfo] objectForKey:@"avatar"]];
    UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
    if (cachedImage == nil) {
        NSURL *url = [NSURL URLWithString:propertyImageURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.delegate = self;
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.didFinishSelector = @selector(avatarDataRequestFinished:);
        [requestQueue addOperation:request];
    } else {
        self.avatarImageView.image = cachedImage;
    }
    //
    self.nameLabel.text = [[MSShareDataCache getUserInfo]objectForKey:@"nickname"];
    self.occupationLabel.text = [[MSShareDataCache getUserInfo]objectForKey:@"occupation"];
    //第一张图遮盖的宽度
    fixedHideWidth = WIDTH_OF_IMAGE*4-self.recommendedServiceScorllView.frame.size.width;
    self.recommendedServiceScorllView.contentOffset = CGPointMake(fixedHideWidth, 0);
    //展示产品的最大数量
    maxImageViewCount = self.recommendedServiceScorllView.frame.size.width/WIDTH_OF_IMAGE;
    int remainWidth = (int)roundf(self.recommendedServiceScorllView.frame.size.width) % WIDTH_OF_IMAGE;
    if (remainWidth>0) {
        maxImageViewCount++;
    }
    // 获取主界面数据
    NSString *urlStr = [NSString stringWithFormat:@"%@r=mydo/home&store_id=%@", HOST_DOMAIN, [[MSShareDataCache getUserInfo] objectForKey:@"store_id"]];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.didFinishSelector = @selector(mainDataRequestFinished:);
    [request startSynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 判断滑动方向
    static float newX = 0;
    static float oldX = 0;
    newX= scrollView.contentOffset.x ;
    if (newX != oldX ) {
        //Left-YES,Right-NO
        if (newX >= oldX) {
            scrollLeftToRight = YES;
        }else{
            scrollLeftToRight = NO;
        }
        oldX = newX;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.leftMenuView.alpha = 0.6;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.leftMenuView.alpha = 0.6;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self adjustImageViewAfterScroll:scrollView];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustImageViewAfterScroll:scrollView];
}

#pragma mark - 主界面数据加载

// 主接口数据下载完毕
- (void)mainDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
        NSLog(@"%@", responseString);
        NSArray *productDatas = [resultData objectForKey:@"products"];
        recommendedImageCount = productDatas.count;
        productInfoDatas = [NSMutableArray arrayWithArray:productDatas];
        [self setupImageViews:recommendedImageCount+ADDITIONAL_IMAGE_COUNT];
        //
        for (NSDictionary *productData in productDatas) {
            NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:[productData objectForKey:@"cover_image"]];
            UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
            if (cachedImage == nil) {
                NSURL *url = [NSURL URLWithString:propertyImageURL];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.delegate = self;
                request.defaultResponseEncoding = NSUTF8StringEncoding;
                request.didFinishSelector = @selector(mainImageRequestFinished:);
                [requestQueue addOperation:request];
            } else {
                [self mainImageFinishLoad:cachedImage];
            }
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

// 从服务器下载推荐产品图片完毕并缓存到本地
- (void)mainImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    [self mainImageFinishLoad:image];
    [MSWebImageCacher cacheWebImage:request.url.description image:image];
}

// 从服务器下载推荐产品图片完毕并缓存到本地
- (void)avatarDataRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    self.avatarImageView.image = image;
    [MSWebImageCacher cacheWebImage:request.url.description image:image];
}

// 将获取到的推荐产品图像进行刷新，如果全部下载完毕则填充对应的循环图片
- (void)mainImageFinishLoad:(UIImage*)image
{
    UIImage *convertedImage = [image convertToGrayscale];
    [originalImages addObject:image];
    [convertedImages addObject:convertedImage];
    UIView *sliderView = [sliderViews objectAtIndex:originalImages.count+1];
    UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView*)[sliderView viewWithTag:-3];
    [activeIndicator stopAnimating];
    UIButton *sliderImageButton = (UIButton*)[sliderView viewWithTag:-1];
    if (originalImages.count == 1) {
        [sliderImageButton setImage:image forState:UIControlStateNormal];
    } else {
        [sliderImageButton setImage:convertedImage forState:UIControlStateNormal];
        UIImageView *imageView = (UIImageView*)[sliderView viewWithTag:-2];
        imageView.hidden = NO;
    }
    if (originalImages.count == recommendedImageCount) {
        [self refactorySlideView];
    }
}

// 服务获取数据失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error.code != 4) {
        NSError *error = [request error];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"数据下载失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSLog(@"HttpRequestError:%@", error.description);
    }
}

#pragma mark - 主界面构建及控制

// 根据数组数据构建主菜单
- (void)setMainMenu:(NSInteger)count
{
    for (int i=0; i<count; i++) {
        UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", MENUITEM_NAME, i]];
        UIImage *selectedBackgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", SELECTED_MENUITEM_NAME, i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(40, 160+i*(MENUITEM_HEIGHT+MENUITEM_INTERVAL), 127, MENUITEM_HEIGHT);
        button.tag = i;
        if (i == 0) {
            [button setBackgroundImage:selectedBackgroundImage forState:UIControlStateNormal];
            lastMainMenuItemButton = button;
        } else {
            [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(mainMenuItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [self.leftMenuView addSubview:button];
    }
    selectedFlagImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SelectedFlag"]];
    selectedFlagImageView.frame = CGRectMake(30, 158, 2, 31);
    [self.leftMenuView addSubview:selectedFlagImageView];
}

/*
 * 由于推荐图片不支持循环滚动，所以最后一张和前两张图无法实现高亮，所以需要将该三个位置进行填补
 */
- (void)refactorySlideView
{
    for (int i=0; i<ADDITIONAL_IMAGE_COUNT-1; i++) {
        [originalImages insertObject:[originalImages objectAtIndex:originalImages.count-1-i] atIndex:0];
        [convertedImages insertObject:[convertedImages objectAtIndex:convertedImages.count-1-i] atIndex:0];
    }
    [originalImages addObject:[originalImages objectAtIndex:ADDITIONAL_IMAGE_COUNT-1]];
    [convertedImages addObject:[convertedImages objectAtIndex:ADDITIONAL_IMAGE_COUNT-1]];
    //
    UIView *sliderView = [sliderViews objectAtIndex:sliderViews.count-1];
    UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView*)[sliderView viewWithTag:-3];
    [activeIndicator stopAnimating];
    UIButton *sliderImageButton = (UIButton*)[sliderView viewWithTag:-1];
    [sliderImageButton setImage:[convertedImages objectAtIndex:convertedImages.count-1] forState:UIControlStateNormal];
    UIImageView *imageView = (UIImageView*)[sliderView viewWithTag:-2];
    imageView.hidden = NO;
    for (int i=0; i<ADDITIONAL_IMAGE_COUNT-1; i++) {
        sliderView = [sliderViews objectAtIndex:i];
        activeIndicator = (UIActivityIndicatorView*)[sliderView viewWithTag:-3];
        [activeIndicator stopAnimating];
        sliderImageButton = (UIButton*)[sliderView viewWithTag:-1];
        [sliderImageButton setImage:[convertedImages objectAtIndex:i] forState:UIControlStateNormal];
        imageView = (UIImageView*)[sliderView viewWithTag:-2];
        imageView.hidden = NO;
    }
    [self adjustImageViewAfterScroll:self.recommendedServiceScorllView];
}

// 将滑动后的推荐图片自动调整到居中位置并切换高亮效果
- (void)adjustImageViewAfterScroll:(UIScrollView*)scrollView
{
    NSInteger lastImageViewIndex = startImageViewIndex;
    if (scrollLeftToRight) { //从左向右滑动
        startImageViewIndex = scrollView.contentOffset.x/WIDTH_OF_IMAGE;
        int remainWidth = (int)roundf(scrollView.contentOffset.x) % WIDTH_OF_IMAGE;
        if (remainWidth-fixedHideWidth > WIDTH_OF_IMAGE/8) {
            startImageViewIndex++;
        }
    } else { //从右向左滑动
        CGFloat lastRemainWidth = scrollView.contentSize.width-scrollView.frame.size.width-scrollView.contentOffset.x;
        int lastRemainImageViewCount = lastRemainWidth/WIDTH_OF_IMAGE;
        int remainWidth = (int)roundf(lastRemainWidth) % WIDTH_OF_IMAGE;
        if (remainWidth > WIDTH_OF_IMAGE/8) {
            lastRemainImageViewCount++;
        }
        startImageViewIndex = sliderViews.count-maxImageViewCount-lastRemainImageViewCount;
    }
    if (startImageViewIndex > maxImageViewIndex) {
        startImageViewIndex = maxImageViewIndex;
    }
    if (startImageViewIndex < 0) {
        startImageViewIndex = 0;
    }
    if ((lastImageViewIndex != startImageViewIndex) && (recommendedImageCount+ADDITIONAL_IMAGE_COUNT == originalImages.count)) {
        AudioServicesPlaySystemSound (_soundFileObject);
        [self refreshLightedImageView:lastImageViewIndex];
    }
    [scrollView setContentOffset:CGPointMake(WIDTH_OF_IMAGE*startImageViewIndex+fixedHideWidth, 0) animated:YES];
    [UIView beginAnimations:@"LeftMenuAlpha" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.2];
    self.leftMenuView.alpha = 1;
    [UIView commitAnimations];
}


// 实现高亮图片的替换，高亮图片固定为开始位置的第三张
- (void)refreshLightedImageView:(NSInteger)lastStartImageViewIndex
{
    UIView *lastSliderView = [sliderViews objectAtIndex:lastStartImageViewIndex+LIGHTED_VIEW_OFFSET];
    UIButton *lastLightedImageButton = (UIButton*)[lastSliderView viewWithTag:-1];
    [lastLightedImageButton setImage:[convertedImages objectAtIndex:lastStartImageViewIndex+LIGHTED_VIEW_OFFSET] forState:UIControlStateNormal];
    UIImageView *lastImageView = (UIImageView*)[lastSliderView viewWithTag:-2];
    lastImageView.hidden = NO;
    //
    UIView * currentSliderView = [sliderViews objectAtIndex:startImageViewIndex+LIGHTED_VIEW_OFFSET];
    UIButton * currentLightedImageButton = (UIButton*)[currentSliderView viewWithTag:-1];
    [currentLightedImageButton setImage:[originalImages objectAtIndex:startImageViewIndex+LIGHTED_VIEW_OFFSET] forState:UIControlStateNormal];
    UIImageView *currentImageView = (UIImageView*)[currentSliderView viewWithTag:-2];
    currentImageView.hidden = YES;
}

// 构建推荐产品图片滚动列表，
- (void)setupImageViews:(NSInteger)count
{
    // ADDITIONAL_IMAGE_COUNT为重复的产品数，将其中最后ADDITIONAL_IMAGE_COUNT-1个产品叠加到最前面，再将第一个叠加最后一个. For instance: FG ABCDEFG A
    for (int i=0; i<ADDITIONAL_IMAGE_COUNT-1; i++) {
        [productInfoDatas insertObject:[productInfoDatas objectAtIndex:productInfoDatas.count-1-i] atIndex:0];
    }
    [productInfoDatas addObject:[productInfoDatas objectAtIndex:ADDITIONAL_IMAGE_COUNT-1]];
    //
    maxImageViewIndex = count-maxImageViewCount;
    // 初始化相关图片数据列表
    originalImages = [NSMutableArray arrayWithCapacity:count];
    convertedImages= [NSMutableArray arrayWithCapacity:count];
    sliderViews = [NSMutableArray arrayWithCapacity:count];
    //
    startImageViewIndex = 0;
    //
    UIImage *defaultLoadImage = [UIImage imageNamed:@"DefaultSlideImage"];
    for (int i = 0;i<count;i++) {
        NSDictionary *productInfoData = [productInfoDatas objectAtIndex:i];
        //
        NSArray *recommendedProductViews = [[NSBundle mainBundle] loadNibNamed:@"MSRecommendedProductView" owner:nil options:nil];
        UIView *recommendedProductView = [recommendedProductViews objectAtIndex:0];
        CGRect frame = recommendedProductView.frame;
        frame.origin.x = WIDTH_OF_IMAGE * i;
        recommendedProductView.frame = frame;
        //
        UIButton *imageButton = (UIButton*)[recommendedProductView viewWithTag:-1];
        imageButton.titleLabel.tag = i;
        [imageButton setImage:defaultLoadImage forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        //
        UIActivityIndicatorView *activeIndicator = (UIActivityIndicatorView*)[recommendedProductView viewWithTag:-3];
        [activeIndicator startAnimating];
        UILabel *titleLabel = (UILabel*)[recommendedProductView viewWithTag:-4];
        titleLabel.textColor = [UIColor getColorWithHexValue:@"3db0c5"];
        titleLabel.text = [productInfoData objectForKey:@"title"];
        UILabel *subTitleLabel = (UILabel*)[recommendedProductView viewWithTag:-5];
        subTitleLabel.textColor = [UIColor getColorWithHexValue:@"666666"];
        subTitleLabel.text = [productInfoData objectForKey:@"subtitle"];
        NSString *description = [productInfoData objectForKey:@"description"];
        UILabel *descriptionLabel = (UILabel*)[recommendedProductView viewWithTag:-6];
        descriptionLabel.textColor = [UIColor getColorWithHexValue:@"8f9092"];
        descriptionLabel.text = description;
        frame = descriptionLabel.frame;
        frame.size = [description sizeWithFont:descriptionLabel.font constrainedToSize:frame.size lineBreakMode:NSLineBreakByTruncatingTail];
        descriptionLabel.frame = frame;
    	[self.recommendedServiceScorllView addSubview:recommendedProductView];
        [sliderViews addObject:recommendedProductView];
    }
    [self.recommendedServiceScorllView setContentSize:CGSizeMake(WIDTH_OF_IMAGE * count, HEIGHT_OF_IMAGE)];
}

// 锁屏控制
- (IBAction)sliderTouchUpIn:(id)sender {
    UISlider *slider = sender;
    if (slider.value < slider.maximumValue/2) {
        slider.value = slider.minimumValue;
        AudioServicesPlaySystemSound (_lockSoundFileObject);
        [self.rootViewController performSelector:@selector(lockSystem)];
    } else {
        slider.value = slider.maximumValue;
    }
}

// 推荐产品点击
- (void)imageButtonPressed:(id)sender
{
    MSCustomizeSolutionDetailViewController *customizeSolutionDetailViewController = nil;
    MSEnvironmentDetailViewController *environmentDetailViewController = nil;
    MSSolutionDetailViewController *solutionDetailViewController = nil;
    MSRecommendedProductDetailViewController *recommendedProductDetailViewController = nil;
    //
    UIButton *button = sender;
    NSDictionary *productInfoData = [productInfoDatas objectAtIndex:button.titleLabel.tag];
    NSNumber *productType = [productInfoData objectForKey:@"product_type"];
    NSNumber *productID = [productInfoData objectForKey:@"product_id"];
    switch (productType.integerValue) {
        case 1:
            environmentDetailViewController = [[MSEnvironmentDetailViewController alloc]initWithNibName:@"MSEnvironmentDetailViewController" bundle:nil serviceID:productID.integerValue];
            environmentDetailViewController.mainViewController = self;
            [self enterServiceDetailView:environmentDetailViewController selector:@selector(setupServiceInfoView)];
            break;
        case 2:
            solutionDetailViewController = [[MSSolutionDetailViewController alloc]initWithNibName:@"MSSolutionDetailViewController" bundle:nil serviceID:productID.integerValue];
            solutionDetailViewController.mainViewController = self;
            [self enterServiceDetailView:solutionDetailViewController selector:@selector(setupServiceInfoView)];
            break;
        case 3:
            recommendedProductDetailViewController = [[MSRecommendedProductDetailViewController alloc]initWithNibName:@"MSRecommendedProductDetailViewController" bundle:nil serviceID:productID.integerValue];
            recommendedProductDetailViewController.mainViewController = self;
            [self enterServiceDetailView:recommendedProductDetailViewController selector:@selector(setupServiceInfoView)];
            break;
        case 4:
            customizeSolutionDetailViewController = [[MSCustomizeSolutionDetailViewController alloc]initWithNibName:@"MSCustomizeSolutionDetailViewController" bundle:nil serviceID:productID.integerValue];
            customizeSolutionDetailViewController.mainViewController = self;
            [self enterServiceDetailView:customizeSolutionDetailViewController selector:@selector(setupServiceInfoView)];
            break;
    }
    NSLog(@"%@",[productInfoData JSONRepresentation]);
    [self.view bringSubviewToFront:self.shopBagButton];
}

#pragma mark - 二级页面切换

// 主菜单点击
- (void)mainMenuItemPressed:(id)sender
{
    if (menuItemCanPress) {
        UIButton *button = (UIButton*)sender;
        if (lastMainMenuItemButton.tag != button.tag) {
            // 加锁主菜单点击
            menuItemCanPress = NO;
            // 完成菜单选中状态的切换
            [lastMainMenuItemButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d", MENUITEM_NAME, lastMainMenuItemButton.tag]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d", SELECTED_MENUITEM_NAME, button.tag]] forState:UIControlStateNormal];
            lastMainMenuItemButton = button;
            CGRect frame = selectedFlagImageView.frame;
            frame.origin.y = button.frame.origin.y-2;
            [UIView beginAnimations:@"MenuItemSelectFlag" context:nil];
            [UIView setAnimationDuration:0.3];
            selectedFlagImageView.frame = frame;
            [UIView commitAnimations];
            // 页面切换，如果是点击“首页”则直接去掉已打开的二级页面，否则加载对应的二级页面
            if (button.tag == 0) {
                lastSecondLevelViewController = nil;
                [secondLevelViewController removeFromMainView:YES];
                secondLevelViewController = nil;
            } else {
                [self enterSecondLevelView:button.tag-1];
            }
        }
    }
}

// 打开二级页面
- (void)enterSecondLevelView:(NSInteger)index
{
    // 动态获取菜单对应的Controller并实例化后加载，加载完后会回调secondViewCallBack方法
    NSString *secondControllerName = [secondLevelViewControllerNames objectAtIndex:index];
    lastSecondLevelViewController = secondLevelViewController;
    secondLevelViewController = [[NSClassFromString(secondControllerName) alloc]initWithNibName:secondControllerName bundle:nil];
    secondLevelViewController.mainViewController = self;
    secondLevelViewController.mainViewCallbackSelector = @selector(secondViewCallBack:);
    CGRect frame = secondLevelViewController.view.frame;
    frame.origin.x = self.leftMenuView.frame.size.width;
    frame.size.width = self.view.frame.size.width - self.leftMenuView.frame.size.width;
    secondLevelViewController.view.frame = frame;
    [self.view insertSubview:secondLevelViewController.view  belowSubview:self.shopbagBackgroundView];
}

// 二级页面加载与释放的回调方法
- (void)secondViewCallBack:(NSDictionary*)data
{
    NSString *type = [data objectForKey:MAINVIEW_CALLBACK_ACTION_TYPE];
    // 加载回调
    if ([type isEqualToString:SECONDACTION_VIEW_EXCHANGE]) {
        // 如果加载当前二级页面之前已有打开的二级页面则需要释放该页面，否则解锁主菜单点击
        if (lastSecondLevelViewController) {
            [lastSecondLevelViewController removeFromMainView:NO];
        } else {
            menuItemCanPress = YES;
        }
    // 释放回调，解锁主菜单点击
    } else if ([type isEqualToString:SECONDACTION_VIEW_REMOVE]) {
        menuItemCanPress = YES;
    }
}

#pragma mark - 购物车列表控制

// 购物车按钮点击，通过该按钮的tag来记录开闭状，0-已关闭 1-已打开
- (IBAction)shopBagButtonPressed:(id)sender {
    UIButton *button = sender;
    if (button.tag == 0) {
        button.tag = -1;
        // 打开半透明遮罩界面
        [self.view insertSubview:hiddenController belowSubview:self.shopBagButton];
        // 初始化购物车列表界面
        if (makeOrderViewController == nil) {
            makeOrderViewController = [[MSMakeOrderViewController alloc]initWithNibName:@"MSMakeOrderViewController" bundle:nil];
            makeOrderViewController.mainViewController = self;
            CGRect frame= makeOrderViewController.view.frame;
            frame.origin.x = self.view.frame.size.width-frame.size.width-20;
            frame.origin.y = self.shopBagButton.frame.origin.y+self.shopBagButton.frame.size.height+10;
            makeOrderViewController.view.frame = frame;
        }
        // 如果当前已有二级界面打开则发送购物车打开消息
        if (secondLevelViewController != nil) {
            [secondLevelViewController sendANotice:[NSDictionary dictionaryWithObjectsAndKeys:MAINACTION_SHOPBAG_BUTTON_DOWN, MAINVIEW_CALLBACK_ACTION_TYPE, nil]];
        }
        [self.view addSubview:makeOrderViewController.view];
    } else {
        [self hideControllerPressed:nil];
    }
}

// 添加产品到购物车，同时实现添加轨迹动画效果
- (void)addToShopBag:(MSShoppedItemData*)productData position:(CGPoint)position
{
    [MSShareDataCache addItemToBag:productData];
    UIImage *animationImage = [UIImage imageNamed:@"ShopButton"];
    UIImageView *animationImageView = [[UIImageView alloc]initWithImage:animationImage];
    animationImageView.frame = CGRectMake(position.x, position.y, animationImage.size.width, animationImage.size.height);
    animationImageView.tag = -100;
    [self.view addSubview:animationImageView];
    [UIView beginAnimations:@"ShopAction" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDidStopSelector:@selector(shopActionAnimationDone:finished:context:)];
    CGRect frame = animationImageView.frame;
    frame.origin.x = self.shopbagBackgroundView.frame.origin.x+self.shopbagBackgroundView.frame.size.width/2;
    frame.origin.y = self.shopbagBackgroundView.frame.origin.y+self.shopbagBackgroundView.frame.size.height/2;
    frame.size.width = 1;
    frame.size.height = 1;
    animationImageView.frame = frame;
    [UIView commitAnimations];
}

// 添加产品动画效果完成后需释放对应的图层并刷新当前已购产品数
- (void)shopActionAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    UIImageView *animationImageView = (UIImageView*)[self.view viewWithTag:-100];
    [animationImageView removeFromSuperview];
    [self refreshShopTipView];
}

// 刷新已购产品数
- (void)refreshShopTipView
{
    NSInteger count = [MSShareDataCache itemsInShopBag].count;
    if ( count > 0) {
        if (count > 99) {
            self.countTipLabel.text = @"...";
        } else {
            self.countTipLabel.text = [NSString stringWithFormat:@"%d", count];
        }
        self.shopBagTipView.hidden = NO;
    } else {
        self.shopBagTipView.hidden = YES;
    }
}

// 关闭购物车
- (void)hideControllerPressed:(id)sender
{
    self.shopBagButton.tag = 0;
    [makeOrderViewController.view removeFromSuperview];
    [hiddenController removeFromSuperview];
    [self refreshShopTipView];
}

#pragma mark - 产品详情页面控制

// 打开产品详情页面并回调详情页的初始化方法
- (void)enterServiceDetailView:(UIViewController*)detailViewController selector:(SEL)selector
{
    // 为实现详情页面渐入的效果，初始化时隐藏在主界面右侧
    [serviceDetailViewControllers addObject:detailViewController];
    CGRect frame = detailViewController.view.frame;
    frame.origin.x = self.view.frame.size.width;
    detailViewController.view.frame = frame;
    [self.view insertSubview:detailViewController.view  belowSubview:self.shopbagBackgroundView];
    if ((selector) && ([detailViewController respondsToSelector:selector])) {
        [detailViewController performSelector:selector];
    }
    // 详情页面渐入动画
    frame.origin.x = 0;
    [UIView beginAnimations:@"EnterDetailView" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    detailViewController.view.frame = frame;
    [UIView commitAnimations];
}

// 关闭产品详情页面
- (void)removeServiceDetailView
{
    if (serviceDetailViewControllers.count > 0) {
        UIViewController *serviceDetailViewController = [serviceDetailViewControllers objectAtIndex:serviceDetailViewControllers.count-1];
        CGRect frame = serviceDetailViewController.view.frame;
        frame.origin.x = self.view.frame.size.width;
        [UIView beginAnimations:@"RemoveDetailView" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeDetailViewAnimationDone:finished:context:)];
        serviceDetailViewController.view.frame = frame;
        [UIView commitAnimations];
    }
}

// 关闭动画效果后释放产品详情页面
- (void)removeDetailViewAnimationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if (serviceDetailViewControllers.count > 0) {
        UIViewController *serviceDetailViewController = [serviceDetailViewControllers objectAtIndex:serviceDetailViewControllers.count-1];
        [serviceDetailViewController.view removeFromSuperview];
        [serviceDetailViewControllers removeObject:serviceDetailViewController];
        serviceDetailViewController = nil;
    }
}

@end

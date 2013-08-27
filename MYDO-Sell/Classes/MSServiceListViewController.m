//
//  MSServiceListViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/28/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSServiceListViewController.h"
#import "ASIHTTPRequest.h"
#import "MSWebImageCacher.h"
#import "MSSystemUtils.h"
#import "MSServiceData.h"

#define IMAGEVIEW_FIXED_WIDTH 270
#define IMAGEVIEW_FIXED_HEIGHT 185
#define LABEL_HORIZONTAL_PADDING 10
#define LABEL_MAX_HEIGHT 73

@interface MSServiceListViewController ()

@end

@implementation MSServiceListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil serviceDatas:(NSArray*)serviceDatas
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.serviceDatas = serviceDatas;
        itemMaxHeightArray = [NSMutableArray array];
        currentPageIndex = 0;
        //
        requestQueue = [[NSOperationQueue alloc]init];
        requestQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initServiceStateItemsMaxHeight];
    //
    NSArray *firstStateDatas = ((MSServiceData*)[self.serviceDatas objectAtIndex:0]).stateItems;
    CGFloat finalStateViewHeight = 0;
    for (int i=0; i<firstStateDatas.count; i++) {
        MSStateItemData *stateItemData = [firstStateDatas objectAtIndex:i];
        finalStateViewHeight += stateItemData.topSpace;
        NSNumber *itemLabelHeight = [itemMaxHeightArray objectAtIndex:i];
        finalStateViewHeight += itemLabelHeight.floatValue;
    }
    CGRect frame = self.view.frame;
    frame.origin.y = 230;
    frame.size.height = finalStateViewHeight+IMAGEVIEW_FIXED_HEIGHT;
    self.view.frame = frame;
    // 显示产品列表
    CGFloat startX = 0;
    UIImage *serviceDefaultImage = [UIImage imageNamed:@"ServiceDefaultImage"];
    for (MSServiceData *serviceData in self.serviceDatas) {
        if (self.canNotBePressed) {
            UIImageView *imageView = [[UIImageView alloc]initWithImage:serviceDefaultImage];
            imageView.frame = CGRectMake(startX, 0, IMAGEVIEW_FIXED_WIDTH, IMAGEVIEW_FIXED_HEIGHT);
            imageView.tag = serviceData.serviceID;
            [self.servicesScrollView addSubview:imageView];
        } else {
            UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            imageButton.frame = CGRectMake(startX, 0, IMAGEVIEW_FIXED_WIDTH, IMAGEVIEW_FIXED_HEIGHT);
            imageButton.tag = serviceData.serviceID;
            [imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [imageButton setImage:serviceDefaultImage forState:UIControlStateNormal];
            [self.servicesScrollView addSubview:imageButton];
        }
        CGFloat startY = IMAGEVIEW_FIXED_HEIGHT;
        for (int i=0; i<serviceData.stateItems.count; i++) {
            MSStateItemData *stateItemData = [serviceData.stateItems objectAtIndex:i];
            startY += stateItemData.topSpace;
            NSNumber *height = [itemMaxHeightArray objectAtIndex:i];
            CGFloat offsetX = startX+LABEL_HORIZONTAL_PADDING/2;
            CGFloat labelFinalWidth = IMAGEVIEW_FIXED_WIDTH-LABEL_HORIZONTAL_PADDING;
            CGFloat finalHeight = height.floatValue;
            if (stateItemData.icon) {
                if (stateItemData.icon.size.height > finalHeight) {
                    finalHeight = stateItemData.icon.size.height;
                    [itemMaxHeightArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:finalHeight]];
                }
                UIImageView *imageView = [[UIImageView alloc]initWithImage:stateItemData.icon];
                imageView.frame = CGRectMake(offsetX, startY+3,  stateItemData.icon.size.width, stateItemData.icon.size.height);
                [self.servicesScrollView addSubview:imageView];
                offsetX = offsetX+stateItemData.icon.size.width+LABEL_HORIZONTAL_PADDING/2;
                labelFinalWidth = labelFinalWidth-stateItemData.icon.size.width-LABEL_HORIZONTAL_PADDING/2;
            }
            CGFloat labelHeight = finalHeight;
            CGSize size = [stateItemData.title sizeWithFont:stateItemData.font constrainedToSize:CGSizeMake(labelFinalWidth, 9999)];
            if (labelHeight > size.height) {
                labelHeight = size.height;
            }
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(offsetX, startY, labelFinalWidth, labelHeight)];
            if (stateItemData.singleLine) {
                label.numberOfLines = 1;
            } else {
                label.numberOfLines = 0;
            }
            label.backgroundColor = [UIColor clearColor];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.font = stateItemData.font;
            label.textColor = stateItemData.color;
            label.text = stateItemData.title;
            label.textAlignment = stateItemData.textAlignment;
            [self.servicesScrollView addSubview:label];
            startY += finalHeight;
        }
        startX += IMAGEVIEW_FIXED_WIDTH;
    }
    _pageCount = self.serviceDatas.count/3;
    if (self.serviceDatas.count%3 > 0) {
        _pageCount++;
    }
    self.servicesScrollView.contentSize = CGSizeMake(self.servicesScrollView.frame.size.width*_pageCount, self.servicesScrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadServiceImages
{
    for (MSServiceData *serviceData in self.serviceDatas) {
        NSString *propertyImageURL = [MSSystemUtils getPropertyImageURL:serviceData.imageURL];
        UIImage *cachedImage = [MSWebImageCacher getCacheImage:propertyImageURL];
        if (cachedImage == nil) {
            NSURL *url = [NSURL URLWithString:propertyImageURL];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.delegate = self;
            request.defaultResponseEncoding = NSUTF8StringEncoding;
            request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:serviceData.serviceID], @"tag", nil];
            request.didFinishSelector = @selector(serviceImageRequestFinished:);
            [requestQueue addOperation:request];
        } else {
            if (self.canNotBePressed) {
                UIImageView *imageView = (UIImageView*)[self.servicesScrollView viewWithTag:serviceData.serviceID];
                imageView.image = cachedImage;
            } else {
                UIButton *imageButton = (UIButton*)[self.servicesScrollView viewWithTag:serviceData.serviceID];
                [imageButton setImage:cachedImage forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - Private

- (void)initServiceStateItemsMaxHeight
{
    for (MSServiceData *serviceData in self.serviceDatas) {
        for (int i=0; i<serviceData.stateItems.count; i++) {
            MSStateItemData *itemData = [serviceData.stateItems objectAtIndex:i];
            CGSize size = CGSizeZero;
            if (itemData.singleLine) {
                size = [itemData.title sizeWithFont:itemData.font];
            } else {
                size = [itemData.title sizeWithFont:itemData.font constrainedToSize:CGSizeMake(IMAGEVIEW_FIXED_WIDTH-LABEL_HORIZONTAL_PADDING, 9999)];
            }
            if (size.height > LABEL_MAX_HEIGHT) {
                size.height = LABEL_MAX_HEIGHT;
            }
            // 设置该条目的最大高度
            if (itemMaxHeightArray.count < i+1) {
                [itemMaxHeightArray addObject:[NSNumber numberWithFloat:size.height]];
            } else {
                NSNumber *maxHeight = [itemMaxHeightArray objectAtIndex:i];
                if (size.height > maxHeight.floatValue) {
                    [itemMaxHeightArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:size.height]];
                }
            }
        }
    }
}

- (void)imageButtonPressed:(id)sender
{
    UIButton *button = sender;
    if (self.callbackDelegate != nil) {
        [self.callbackDelegate serviceListTouchCallBack:button.tag];
    }
}

- (void)cancelAllOperations
{
    [requestQueue cancelAllOperations];
    requestQueue = nil;
}

#pragma mark -  ASIHttpRequest Delegate

- (void)serviceImageRequestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    UIImage *image = [UIImage imageWithData:responseData];
    NSNumber *tag = [request.userInfo objectForKey:@"tag"];
    if (self.canNotBePressed) {
        UIImageView *imageView = (UIImageView*)[self.servicesScrollView viewWithTag:tag.integerValue];
        imageView.image = image;
    } else {
        UIButton *button = (UIButton*)[self.servicesScrollView viewWithTag:tag.integerValue];
        [button setImage:image forState:UIControlStateNormal];
    }
    [MSWebImageCacher cacheWebImage:request.url.description image:image];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed:%@", request.url.description);
    NSError *error = [request error];
    if (error.code != 4) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"数据下载失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSLog(@"HttpRequestError:%@", error.description);
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    if (pageIndex != currentPageIndex) {
        if (self.callbackDelegate != nil) {
            [self.callbackDelegate serviceListScrollCallBack:pageIndex];
        }
        currentPageIndex = pageIndex;
    }
}

@end

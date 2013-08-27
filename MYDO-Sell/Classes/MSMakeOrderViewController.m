//
//  MSMakeOrderViewController.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/22/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSMakeOrderViewController.h"
#import "MSShareDataCache.h"
#import "MSShopBagListCell.h"
#import "MSShoppedItemData.h"
#import "UIColor+HexToRGBColor.h"
#import "MSMainViewController.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "SBJson.h"

@interface MSMakeOrderViewController ()

@end

@implementation MSMakeOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *backgroundImage = [UIImage imageNamed:@"ShoppingFrame"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    self.backgroundImageView.image = backgroundImage;
    [self.OrderButton setImage:[UIImage imageNamed:@"OrderButton"] forState:UIControlStateNormal];
    [self.OrderButton setImage:[UIImage imageNamed:@"OrderButtonSelected"] forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.orderedItemTableView reloadData];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%.2f", [self priceCount]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (CGFloat)priceCount
{
    CGFloat total = 0;
    for (MSShoppedItemData *itemData in [MSShareDataCache itemsInShopBag]) {
        total += itemData.price;
    }
    return total;
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MSShareDataCache itemsInShopBag].count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSShoppedItemData *itemData = [[MSShareDataCache itemsInShopBag]objectAtIndex:indexPath.row];
    static NSString *shoppedItemIdentifier = @"ShoppedItemIdentifier";
    MSShopBagListCell *cell = (MSShopBagListCell*)[tableView
                                      dequeueReusableCellWithIdentifier:shoppedItemIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MSShopBagListCell" owner:self options:nil];
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[MSShopBagListCell class]]) {
                cell = (MSShopBagListCell*)oneObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }      
    }
    cell.itemNameLabel.text = itemData.name;
    cell.itemImageView.image = itemData.image;
    cell.itemPriceLabel.text = [NSString stringWithFormat:@"%.2f", itemData.price];
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row%2 == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.contentView.backgroundColor = [UIColor getColorWithHexValue:@"f6f6f6"];
    }
    return cell;
}

- (IBAction)makeOrderButtonPressed:(id)sender {
    NSArray *shoppedItems = [MSShareDataCache itemsInShopBag];
    if (shoppedItems.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提交订单" message:@"是否确定要提交该订单？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
        alertView.tag = 0;
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提交订单" message:@"请先选购您心宜的项目！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertView.tag = 1;
        [alertView show];
    }
}

- (void)deleteButtonPressed:(id)sender
{
    UIButton *button = sender;
    MSShoppedItemData *itemData = [[MSShareDataCache itemsInShopBag]objectAtIndex:button.tag];
    [MSShareDataCache removeItemFromBag:itemData];
    [self.orderedItemTableView reloadData];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%.2f", [self priceCount]];
}

- (void)postToServer
{
    NSString *urlStr = [NSString stringWithFormat:@"%@r=mydo/postorder",HOST_DOMAIN];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[self packPostDataJSONRepresentation] forKey:@"order"];
//    [request setCompletionBlock:^{
//        NSString *responseString = [request responseString];
//        NSLog(@"Response: %@", responseString);
//    }];
//    [request setFailedBlock:^{
//        NSError *error = [request error];
//        NSLog(@"Error: %@", error.localizedDescription);
//    }];
    [request startSynchronous];
}

- (NSString*)packPostDataJSONRepresentation
{
    NSMutableDictionary *postDataDictionary = [NSMutableDictionary dictionary];
    [postDataDictionary setObject:[[MSShareDataCache getUserInfo] objectForKey:@"store_id"] forKey:@"store_id"];
    [postDataDictionary setObject:[[MSShareDataCache getUserInfo] objectForKey:@"user_id"] forKey:@"user_id"];
    NSMutableArray *array = [NSMutableArray array];
    for (MSShoppedItemData *itemData in [MSShareDataCache itemsInShopBag]) {
        NSDictionary *itemPostData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:itemData.type], @"type", [NSNumber numberWithInteger:itemData.itemID], @"id", itemData.name, @"title", [NSNumber numberWithFloat:itemData.price], @"retail_price", [NSNumber numberWithFloat:itemData.priceForVIP], @"vip_price", nil];
        [array addObject:itemPostData];
    }
    [postDataDictionary setObject:array forKey:@"order_info"];
    NSLog(@"%@", [postDataDictionary JSONRepresentation]);
    return [postDataDictionary JSONRepresentation];
}

#pragma mark - ASIHttpRequest Delegate

- (void)storeDataRequestFinished:(ASIHTTPRequest *)request
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *responseString = [request responseString];
    NSDictionary *resultData = [parser objectWithString:responseString];
    NSLog(@"%@", responseString);
    NSNumber *status = [resultData objectForKey:@"status"];
    if (status.intValue == 200) {
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"获取服务器数据错误" message:[resultData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    };
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error.code != 4) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"数据下载失败" message:error.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        NSLog(@"HttpRequestError:%@", error.description);
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag==0)&&(buttonIndex == 0)) {
        [self postToServer];
        [MSShareDataCache clearItems];
    }
    [self.mainViewController hideControllerPressed:self];
}

@end

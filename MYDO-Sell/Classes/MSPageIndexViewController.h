//
//  MSPageIndexViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/21/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPageIndexViewController : UIViewController
{
    CGFloat moveStep;
    NSInteger stepTotalCount;
}

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pageIndexLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *pageLineImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageCount:(NSInteger)pageCount;
- (void)moveTo:(NSInteger)pageIndex;
- (void)resetPageCount:(NSInteger)pageCount;

@end

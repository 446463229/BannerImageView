//
//  ViewController.m
//  GGBannerView
//
//  Created by kimi on 6/14/16.
//  Copyright © 2016 kimi. All rights reserved.
//

#import "ViewController.h"
#import "GGBannerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GGBannerView *imgScrollView = [[GGBannerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];

    imgScrollView.pageColor = [UIColor blackColor];
    imgScrollView.pageSelColor = [UIColor blueColor];
    [self.view addSubview:imgScrollView];
    imgScrollView.pics = @[@"http://d03.res.meilishuo.net/pic/_o/5d/39/5c14d65b47e09381e4e002776eb7_750_659.c1.jpg", @"http://img4.duitang.com/uploads/item/201205/08/20120508205221_4VjUL.jpeg", @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1465904888&di=0b90e738346160053a311723e77219a2&src=http://img0w.pconline.com.cn/pconline/1203/22/2714157_5.jpg", @"http://img.pconline.com.cn/images/upload/upc/tx/sns/1305/08/c3/20691453_1368018473835_650x650.jpg", @"http://imgq.duitang.com/uploads/item/201501/12/20150112135712_BCcmQ.thumb.700_0.jpeg"];
    
    [imgScrollView returnIndex:^(NSInteger index) {
        NSLog(@"clicked %zd page", index);
    }];
    
    [imgScrollView reloadView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

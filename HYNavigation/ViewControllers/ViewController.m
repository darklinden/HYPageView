//
//  ViewController.m
//  HYNavigation
//
//  Created by runlhy on 16/9/26.
//  Copyright © 2016年 Pengcent. All rights reserved.
//

#import "ViewController.h"
#import "HYPageView.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView addSubview:[self test4]];
}

- (HYPageView *)test4 {

    HYPageView *pageView = [[HYPageView alloc]
            initWithTitles:
                    @[
                            @"一",
                            @"二二",
                            @"三三三",
                            @"四四四四",
                            @"五五",
                            @"六六六",
                            @"七",
                            @"八八八八",
                            @"九九",
                            @"十十十十十十十十十十"
                    ]
       withViewControllers:
               @[
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController",
                       @"SubViewController"
               ]];
    
    pageView.pageViewStyle = HYPageViewStyleA;
    pageView.lineBottomColor = [UIColor orangeColor];
    pageView.selectedColor = [UIColor blackColor];
    pageView.unselectedColor = [UIColor lightGrayColor];
    pageView.selectedFont = [UIFont boldSystemFontOfSize:20];
    pageView.unselectedFont = [UIFont systemFontOfSize:18];
    pageView.defaultSubscript = 0;
    pageView.lineBottomWidthPercent = 0.8;
    return pageView;
}

@end

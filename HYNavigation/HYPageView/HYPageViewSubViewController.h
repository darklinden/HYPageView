//
//  HYPageViewSubViewController.h
//  HYNavigation
//
//  Created by whoami on 2019/12/25.
//  Copyright © 2019 Pengcent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPageViewSubViewController : UIViewController

+ (instancetype)create;

- (void)willShowInHYPageView;

- (void)willHideInHYPageView;

@end

NS_ASSUME_NONNULL_END

//
//  HYPageView.h
//  HYNavigation
//
//  Created by runlhy on 16/9/27.
//  Copyright © 2016年 Pengcent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickTitleBlock)(NSInteger);

@interface HYPageView : UIScrollView
typedef NS_ENUM(NSInteger, HYPageViewStyle) {
    HYPageViewStyleA,
    HYPageViewStyleB
};

/** TitleButton Block */
@property(nonatomic, copy) ClickTitleBlock clickTitleBlock;

// Personalized configuration properties
@property(nonatomic, strong) UIColor *lineBottomColor;

/**
 default 1.0f.
 */
@property(nonatomic, assign) CGFloat lineBottomWidthPercent;

@property(nonatomic, strong) UIFont *selectedFont;
@property(nonatomic, strong) UIFont *unselectedFont;
@property(nonatomic, strong) UIColor *selectedColor;
@property(nonatomic, strong) UIColor *unselectedColor;
@property(nonatomic, strong) UIColor *topTabBottomLineColor;
@property(nonatomic, assign) CGFloat leftSpace;
@property(nonatomic, assign) CGFloat rightSpace;
@property(nonatomic, assign) CGFloat minSpace;
@property(nonatomic, assign) NSInteger defaultSubscript;
@property(nonatomic, assign) HYPageViewStyle pageViewStyle;

/**
 default 44.
 */
@property(nonatomic, assign) CGFloat tabHeight;

/**
 default 4.
 */
@property(nonatomic, assign) CGFloat tabLineHeight;
@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UIButton *rightButton;

/**
 default YES.
 */
@property(nonatomic, assign) BOOL isAdapteNavigationBar;

/**
 default YES.
 */
@property(nonatomic, assign) BOOL isTranslucent;

/**
 default YES ,Valid when only one page can be filled with all buttons
 */
@property(nonatomic, assign) BOOL isAverage;

/**
 default YES .
 */
@property(nonatomic, assign) BOOL isShowTopTabBottomLine;

/**
 default YES .
 */
@property(nonatomic, assign) BOOL bodyPageBounces;

/**
 default YES .
 */
@property(nonatomic, assign) BOOL bodyPageScrollEnabled;

/**
 default NO .
 */
@property(nonatomic, assign) BOOL topTabBounces;

/**
 Initializes and returns a newly allocated view object with the specified frame rectangle.

 @param titles      Some title
 @param controllers Name of some controllers, should be sub class of HYPageViewSubViewController
 @param parameters  You need to set a property called "parameter" for your controller to receive.
 
 @return self
 */
- (instancetype)initWithTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers;

@end

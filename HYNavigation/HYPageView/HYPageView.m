//
//  HYPageView.m
//  HYNavigation
//
//  Created by runlhy on 16/9/27.
//  Copyright © 2016年 Pengcent. All rights reserved.
//
#define LEFT_SPACE 20
#define RIGHT_SPACE 20
#define MIN_SPACING 20
#define TOPBOTTOMLINEBOTTOM_HEIGHT .5
#define SELECTED_COLOR [UIColor colorWithRed:65/255.0 green:105/255.0 blue:225/255.0 alpha:1.0]
#define UNSELECTED_COLOR [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
#define TPOTABBOTTOMLINE_COLOR [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]

#import "HYPageView.h"
#import "HYPageViewSubViewController.h"
#import <objc/runtime.h>

@interface HYPageView () <UIScrollViewDelegate>

@property(strong, nonatomic) UIScrollView *topTabScrollView;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(assign, nonatomic) NSInteger currentPage;
@property(strong, nonatomic) NSMutableArray *strongArray;
@property(weak, nonatomic) UIViewController *rootViewController;

@end

@implementation HYPageView {

    NSInteger _topTabScrollViewWidth;

    NSArray        <NSString *> *_titles;
    NSMutableArray *_viewControllers;
    UIView *_lineBottom;
    NSMutableArray *_titleButtons;
    NSMutableArray *_titleSizeArray;
    NSMutableArray *_centerPoints;

    NSMutableArray *_width_k_array;
    NSMutableArray *_width_b_array;
    NSMutableArray *_point_k_array;
    NSMutableArray *_point_b_array;
}

- (void)dealloc {
    //NSLog(@"%@",self.class);
    [self removeObserver:self forKeyPath:@"currentPage"];
}

#pragma mark - set Method

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self updateSelectedPage:0];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor {
    _unselectedColor = unselectedColor;
    [self updateSelectedPage:0];
}

- (void)setLineBottomColor:(UIColor *)lineBottomColor {
    _lineBottomColor = lineBottomColor;
    _lineBottom.backgroundColor = _lineBottomColor;
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont;
    [self updateSelectedPage:0];
}

- (void)setUnselectedFont:(UIFont *)unselectedFont {
    _unselectedFont = unselectedFont;
    [self updateSelectedPage:0];
}

#pragma mark - Initializes Method

- (instancetype)initWithTitles:(NSArray *)titles withViewControllers:(NSArray *)controllers {
    self = [super init];

    if (self) {
        self.scrollsToTop = NO;
        _lineBottomWidthPercent = 1.0f;
        _selectedColor = SELECTED_COLOR;
        _unselectedColor = UNSELECTED_COLOR;
        _leftSpace = LEFT_SPACE;
        _rightSpace = RIGHT_SPACE;
        _minSpace = MIN_SPACING;
        _topTabBottomLineColor = TPOTABBOTTOMLINE_COLOR;
        _titles = titles;
        _tabHeight = 44;
        _tabLineHeight = 4;
        _viewControllers = [NSMutableArray arrayWithArray:controllers];
        _isAverage = YES;
        _isShowTopTabBottomLine = YES;
        _isTranslucent = YES;
        _isAdapteNavigationBar = YES;
        _bodyPageBounces = YES;
        _bodyPageScrollEnabled = YES;
        _topTabBounces = NO;
    }
    return self;
}

- (void)didMoveToSuperview {
    if (self.superview) {
        NSLayoutConstraint *top = [NSLayoutConstraint
                constraintWithItem:self
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                            toItem:self.superview
                         attribute:NSLayoutAttributeTop
                        multiplier:1.0
                          constant:0.f];

        NSLayoutConstraint *bottom = [NSLayoutConstraint
                constraintWithItem:self
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                            toItem:self.superview
                         attribute:NSLayoutAttributeBottom
                        multiplier:1.0
                          constant:0.f];

        NSLayoutConstraint *leading = [NSLayoutConstraint
                constraintWithItem:self
                         attribute:NSLayoutAttributeLeading
                         relatedBy:NSLayoutRelationEqual
                            toItem:self.superview
                         attribute:NSLayoutAttributeLeading
                        multiplier:1.0
                          constant:0.f];

        NSLayoutConstraint *trailing = [NSLayoutConstraint
                constraintWithItem:self
                         attribute:NSLayoutAttributeTrailing
                         relatedBy:NSLayoutRelationEqual
                            toItem:self.superview
                         attribute:NSLayoutAttributeTrailing
                        multiplier:1.0
                          constant:0.f];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview addConstraints:@[top, bottom, leading, trailing]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _rootViewController = [self findViewController:self];
    _unselectedFont = _unselectedFont ? _unselectedFont : [UIFont systemFontOfSize:16];
    _selectedFont = _selectedFont ? _selectedFont : [UIFont boldSystemFontOfSize:17];
    [self addSubview:self.scrollView];
    [self addSubview:self.topTabScrollView];
}

#pragma mark - lazy

- (UIScrollView *)topTabScrollView {
    if (!_topTabScrollView) {
        CGFloat leftWidth = 0;
        CGFloat rightWidth = 0;
        if (self.leftButton) {
            leftWidth = self.leftButton.bounds.size.width;
        }
        if (self.rightButton) {
            rightWidth = self.rightButton.bounds.size.width;
        }
        _topTabScrollViewWidth = self.frame.size.width - leftWidth - rightWidth;
        CGRect frame = CGRectMake(leftWidth, 0, _topTabScrollViewWidth, self.tabHeight);
        _topTabScrollView = [[UIScrollView alloc] initWithFrame:frame];

        _topTabScrollView.showsHorizontalScrollIndicator = NO;
        _topTabScrollView.scrollsToTop = NO;
        _topTabScrollView.bounces = _topTabBounces;

        CGFloat totalWidth = 0;
        _titleSizeArray = [NSMutableArray array];
        CGFloat equalX = _leftSpace;
        NSMutableArray *equalIntervals = [NSMutableArray array];

        for (NSInteger i = 0; i < _titles.count; i++) {
            CGSize titleSize = [_titles[i] sizeWithAttributes:@{NSFontAttributeName: _selectedFont}];
            [_titleSizeArray addObject:[NSValue valueWithCGSize:titleSize]];
            totalWidth += titleSize.width;
            [equalIntervals addObject:[NSNumber numberWithFloat:(equalX + titleSize.width / 2)]];
            equalX += _minSpace + titleSize.width;
        }

        CGFloat dividend = _titles.count > 1 ? _titles.count - 1 : 1;
        CGFloat minWidth = (_topTabScrollViewWidth - totalWidth - _leftSpace - _rightSpace) / dividend;
        CGFloat averageX = _leftSpace;
        if (_isAverage) {
            minWidth = (_topTabScrollViewWidth - totalWidth) / (_titles.count + 1);
            averageX = minWidth;
        }
        NSMutableArray *averageIntervals = [NSMutableArray array];
        for (NSInteger i = 0; i < _titles.count; i++) {
            [averageIntervals addObject:[NSNumber numberWithDouble:(averageX + [_titleSizeArray[i] CGSizeValue].width / 2)]];
            averageX += minWidth + [_titleSizeArray[i] CGSizeValue].width;
        }
        totalWidth += (_titles.count - 1) * _minSpace + _leftSpace + _rightSpace;
        NSMutableArray *centerPoints = [NSMutableArray array];
        if (totalWidth > _topTabScrollViewWidth) {
            centerPoints = equalIntervals;
        } else {
            centerPoints = averageIntervals;
            totalWidth = _topTabScrollViewWidth;
        }
        _centerPoints = centerPoints;

        NSMutableArray *calculationArray = [self calculationAstyle];
        if (self.pageViewStyle == HYPageViewStyleB) {
            calculationArray = [self calculationBstyle];
        }

        _width_k_array = calculationArray[0];
        _width_b_array = calculationArray[1];
        _point_k_array = calculationArray[2];
        _point_b_array = calculationArray[3];

        _topTabScrollView.contentSize = CGSizeMake(totalWidth, 0);
        _titleButtons = [NSMutableArray array];
        for (NSInteger i = 0; i < _titles.count; i++) {
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            titleButton.tag = i;
            [_titleButtons addObject:titleButton];
            titleButton.titleLabel.font = _unselectedFont;
            [titleButton setTitle:_titles[i] forState:UIControlStateNormal];
            CGFloat x = [_centerPoints[i] floatValue];
            CGFloat width = [_titleSizeArray[i] CGSizeValue].width;
            CGRect buttonFrame = CGRectMake(x - width / 2, 0, width, self.tabHeight);
            titleButton.frame = buttonFrame;
            [_topTabScrollView addSubview:titleButton];
            [titleButton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self updateSelectedPage:self.defaultSubscript];
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width * self.defaultSubscript, 0) animated:NO];


        if (_isShowTopTabBottomLine) {
            UIView *topTabBottomLine = [UIView new];
            topTabBottomLine.frame = CGRectMake(-totalWidth, self.tabHeight - TOPBOTTOMLINEBOTTOM_HEIGHT, totalWidth * 3, TOPBOTTOMLINEBOTTOM_HEIGHT);
            topTabBottomLine.backgroundColor = _topTabBottomLineColor;
            [_topTabScrollView addSubview:topTabBottomLine];
        }

        _lineBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabHeight - self.tabLineHeight, [_titleSizeArray[self.defaultSubscript] CGSizeValue].width * self.lineBottomWidthPercent, self.tabLineHeight)];
        _lineBottom.center = CGPointMake([centerPoints[self.defaultSubscript] floatValue], _lineBottom.center.y);
        _lineBottom.backgroundColor = _lineBottomColor;
        [_topTabScrollView addSubview:_lineBottom];
    }
    return _topTabScrollView;
}

- (NSMutableArray *)calculationAstyle {

    NSMutableArray *width_k_array = [NSMutableArray array];
    NSMutableArray *width_b_array = [NSMutableArray array];
    NSMutableArray *point_k_array = [NSMutableArray array];
    NSMutableArray *point_b_array = [NSMutableArray array];

    NSMutableArray *calculationArray = [NSMutableArray array];

    for (NSInteger i = 0; i < _titles.count - 1; i++) {
        CGFloat k = ([_titleSizeArray[i + 1] CGSizeValue].width - [_titleSizeArray[i] CGSizeValue].width) / self.frame.size.width;
        CGFloat b = [_titleSizeArray[i] CGSizeValue].width - k * i * self.frame.size.width;
        [width_k_array addObject:[NSNumber numberWithFloat:k]];
        [width_b_array addObject:[NSNumber numberWithFloat:b]];
    }
    for (NSInteger i = 0; i < _titles.count - 1; i++) {
        CGFloat k = ([_centerPoints[i + 1] floatValue] - [_centerPoints[i] floatValue]) / self.frame.size.width;
        CGFloat b = [_centerPoints[i] floatValue] - k * i * self.frame.size.width;

        [point_k_array addObject:[NSNumber numberWithFloat:k]];
        [point_b_array addObject:[NSNumber numberWithFloat:b]];
    }
    [calculationArray addObjectsFromArray:@[width_k_array, width_b_array, point_k_array, point_b_array]];

    return calculationArray;
}

- (NSMutableArray *)calculationBstyle {

    NSMutableArray *width_k_array = [NSMutableArray array];
    NSMutableArray *width_b_array = [NSMutableArray array];
    NSMutableArray *point_k_array = [NSMutableArray array];
    NSMutableArray *point_b_array = [NSMutableArray array];

    NSMutableArray *calculationArray = [NSMutableArray array];

    for (NSInteger i = 0; i < _titles.count - 1; i++) {

        CGFloat startPointX = [_centerPoints[i] floatValue] - ([_titleSizeArray[i] CGSizeValue].width / 2);
        CGFloat endPointX = ([_centerPoints[i + 1] floatValue] + ([_titleSizeArray[i + 1] CGSizeValue].width / 2));
        CGFloat distance = endPointX - startPointX;

        CGFloat k0 = 2 * (distance - [_titleSizeArray[i] CGSizeValue].width) / self.frame.size.width;
        CGFloat b0 = [_titleSizeArray[i] CGSizeValue].width - k0 * (2 * i) * (self.frame.size.width / 2);

        [width_k_array addObject:[NSNumber numberWithFloat:k0]];
        [width_b_array addObject:[NSNumber numberWithFloat:b0]];

        CGFloat k1 = 2 * ([_titleSizeArray[i + 1] CGSizeValue].width - distance) / self.frame.size.width;
        CGFloat b1 = distance - k1 * (2 * i + 1) * self.frame.size.width / 2;

        [width_k_array addObject:[NSNumber numberWithFloat:k1]];
        [width_b_array addObject:[NSNumber numberWithFloat:b1]];
    }

    for (NSInteger i = 0; i < _titles.count - 1; i++) {

        CGFloat startPointX = [_centerPoints[i] floatValue] - ([_titleSizeArray[i] CGSizeValue].width / 2);
        CGFloat endPointX = ([_centerPoints[i + 1] floatValue] + ([_titleSizeArray[i + 1] CGSizeValue].width / 2));
        CGFloat distance = endPointX - startPointX;
        CGFloat midpointX = startPointX + distance / 2;

        CGFloat k0 = (midpointX - [_centerPoints[i] floatValue]) / self.frame.size.width * 2;
        CGFloat b0 = [_centerPoints[i] floatValue] - k0 * (2 * i) * self.frame.size.width / 2;

        [point_k_array addObject:[NSNumber numberWithFloat:k0]];
        [point_b_array addObject:[NSNumber numberWithFloat:b0]];


        CGFloat k1 = ([_centerPoints[i + 1] floatValue] - midpointX) / self.frame.size.width * 2;
        CGFloat b1 = midpointX - k1 * (2 * i + 1) * self.frame.size.width / 2;

        [point_k_array addObject:[NSNumber numberWithFloat:k1]];
        [point_b_array addObject:[NSNumber numberWithFloat:b1]];
    }
    [calculationArray addObjectsFromArray:@[width_k_array, width_b_array, point_k_array, point_b_array]];

    return calculationArray;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];

        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = _bodyPageBounces;
        _scrollView.scrollEnabled = _bodyPageScrollEnabled;

        CGFloat y = 0;
        _scrollView.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * _titles.count, 0);
        [self addObserver:self forKeyPath:@"currentPage" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        self.currentPage = self.defaultSubscript;
    }
    return _scrollView;
}

- (NSMutableArray *)strongArray {
    if (!_strongArray) {
        _strongArray = [NSMutableArray arrayWithArray:_viewControllers];
    }
    return _strongArray;
}

#pragma mark - Calculation Method

- (CGFloat)getTitleWidth:(CGFloat)offset {
    NSInteger index = (NSInteger) (offset / self.frame.size.width);

    if (self.pageViewStyle == HYPageViewStyleB) {
        index = (NSInteger) (offset / self.frame.size.width * 1.99999);
    }

    CGFloat k = [_width_k_array[index] floatValue];
    CGFloat b = [_width_b_array[index] floatValue];
    CGFloat x = offset;
    return k * x + b;
}

- (CGFloat)getTitlePoint:(CGFloat)offset {
    NSInteger index = (NSInteger) (offset / self.frame.size.width);

    if (self.pageViewStyle == HYPageViewStyleB) {
        index = (NSInteger) (offset / self.frame.size.width * 1.99999);
    }
    CGFloat k = [_point_k_array[index] floatValue];
    CGFloat b = [_point_b_array[index] floatValue];
    CGFloat x = offset;
    return k * x + b;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPage = (NSInteger) ((scrollView.contentOffset.x + self.frame.size.width / 2) / self.frame.size.width);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.currentPage = (NSInteger) ((scrollView.contentOffset.x + self.frame.size.width / 2) / self.frame.size.width);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= self.frame.size.width * (_titles.count - 1)) {
        return;
    }
    _lineBottom.center = CGPointMake([self getTitlePoint:scrollView.contentOffset.x], _lineBottom.center.y);
    _lineBottom.bounds = CGRectMake(0, 0, [self getTitleWidth:scrollView.contentOffset.x] * self.lineBottomWidthPercent, self.tabLineHeight);
    CGFloat page = (NSInteger) ((scrollView.contentOffset.x + self.frame.size.width / 2) / self.frame.size.width);
    [self updateSelectedPage:page];
}

#pragma mark - My Method

- (void)clickAction:(UIButton *)button {
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width * button.tag, 0) animated:YES];

    if (self.clickTitleBlock) {
        self.clickTitleBlock(button.tag);
    }
}

- (void)updateSelectedPage:(NSInteger)page {
    for (UIButton *button in _titleButtons) {
        if (button.tag == page) {
            [button setTitleColor:_selectedColor forState:UIControlStateNormal];
            button.titleLabel.font = _selectedFont;
        } else {
            [button setTitleColor:_unselectedColor forState:UIControlStateNormal];
            button.titleLabel.font = _unselectedFont;
        }
    }
}

- (UIViewController *)findViewController:(UIView *)sourceView {
    id target = sourceView;
    while (target) {
        target = ((UIResponder *) target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPage"]) {
        NSInteger page = [change[@"new"] integerValue];
        CGFloat offset = [_centerPoints[page] floatValue];
        if (offset < _topTabScrollViewWidth / 2) {
            [_topTabScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else if (offset + _topTabScrollViewWidth / 2 < _topTabScrollView.contentSize.width) {
            [_topTabScrollView setContentOffset:CGPointMake(offset - _topTabScrollViewWidth / 2, 0) animated:YES];
        } else {
            [_topTabScrollView setContentOffset:CGPointMake(_topTabScrollView.contentSize.width - _topTabScrollViewWidth, 0) animated:YES];
        }
        for (NSInteger i = 0; i < _viewControllers.count; i++) {
            if (page == i) {

                NSString *className = @"HYPAGEVIEW_Controller";

                if ([[_viewControllers[page] class] isSubclassOfClass:[NSString class]]) {
                    className = _viewControllers[page];
                }

                for (NSInteger j = 0; j < self.strongArray.count; j++) {
                    id obj = self.strongArray[j];
                    if ([[obj class] isSubclassOfClass:[HYPageViewSubViewController class]]) {
                        HYPageViewSubViewController *viewController = obj;
                        if (j == page) {
                            [viewController willShowInHYPageView];
                        } else {
                            [viewController willHideInHYPageView];
                        }
                        
                        if ([viewController.view.class isSubclassOfClass:[UIScrollView class]]) {
                            UIScrollView *view = (UIScrollView *) viewController.view;
                            if (j == page) {
                                view.scrollsToTop = YES;
                            } else {
                                view.scrollsToTop = NO;
                            }
                        }
                        
                        if ([NSStringFromClass([viewController.view class]) isEqualToString:@"UICollectionViewControllerWrapperView"]) {
                            UIScrollView *view = (UIScrollView *) viewController.view.subviews[0];
                            if (j == page) {
                                view.scrollsToTop = YES;
                            } else {
                                view.scrollsToTop = NO;
                            }
                        }
                    }
                }

                //Create only once
                if ([className isEqualToString:@"HYPAGEVIEW_AlreadyCreated"]) {
                    return;
                }

                HYPageViewSubViewController *viewController = nil;
                if (![className isEqualToString:@"HYPAGEVIEW_Controller"]) {
                    Class class = NSClassFromString(className);
                    viewController = [class create];
                } else {
                    viewController = _viewControllers[page];
                }

                self.strongArray[i] = viewController;

                CGFloat offset = self.tabHeight;
                
                CGRect frame = CGRectMake(self.frame.size.width * i, offset, self.frame.size.width, _scrollView.bounds.size.height - offset);

                if ([viewController.view.class isSubclassOfClass:[UIScrollView class]]) {
                    UIScrollView *view = (UIScrollView *) viewController.view;
                    view.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
                    view.contentOffset = CGPointMake(0, -offset);
                    frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, _scrollView.bounds.size.height);
                }
                if ([NSStringFromClass([viewController.view class]) isEqualToString:@"UICollectionViewControllerWrapperView"]) {
                    UIScrollView *view = (UIScrollView *) viewController.view.subviews[0];
                    view.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
                    view.contentOffset = CGPointMake(0, -offset);
                    frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, _scrollView.bounds.size.height);
                }
                viewController.view.frame = frame;
                [self.scrollView addSubview:viewController.view];
                _viewControllers[page] = @"HYPAGEVIEW_AlreadyCreated";

                [_rootViewController addChildViewController:viewController];
            }
        }
    }
}

@end

//
//  JPPopupMenuView.m
//  JPPlayer
//
//  Created by Prime on 3/12/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPPopupMenuViewController.h"
#import "JPPopupMenuRootViewController.h"
#import "JPTrackHeader.h"

@interface JPPopupMenuViewController()

@property (strong, nonatomic) UIView *backgroundContainerView;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) JPTrackHeader *headerView;
@property (strong, nonatomic) UINavigationController *navigationVC;
@property (strong, nonatomic) UIView *navigationContainer;

@property (strong, nonatomic) SPTPartialTrack *track;

@property (strong, nonatomic) JPPopupMenuRootViewController *rootVC;

@end

@implementation JPPopupMenuViewController

static id defaultInstance;

+ (instancetype)defaultInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;

        _backgroundContainerView = [[UIView alloc] init];
        _backgroundContainerView.hidden = YES;
        [window addSubview:_backgroundContainerView];
        [_backgroundContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];

        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_backgroundView addGestureRecognizer:tap];
        [_backgroundContainerView addSubview:_backgroundView];
        [_backgroundView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_backgroundContainerView);
        }];

        self.view.backgroundColor = [UIColor JPBackgroundColor];
        self.view.layer.cornerRadius = 10.f;
        self.view.clipsToBounds = YES;
        [_backgroundContainerView addSubview:self.view];
        [self.view makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(PopupMenuWidth));
            make.height.equalTo(@(JPTrackHeaderHeight));
            make.right.equalTo(_backgroundContainerView).offset(-(8.f + SmallButtonWidth + 8.f));
            make.centerY.equalTo(_backgroundContainerView).priorityLow();
            make.top.greaterThanOrEqualTo(_backgroundContainerView.top).offset(20.f);
            make.bottom.lessThanOrEqualTo(_backgroundContainerView.bottom).offset(-20.f);
        }];

        _navigationContainer = [[UIView alloc] init];
        [self.view addSubview:_navigationContainer];

        _headerView = [[JPTrackHeader alloc] init];
        [self.view addSubview:_headerView];
        [_headerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.equalTo(@(JPTrackHeaderHeight));
        }];

        _navigationVC = [[UINavigationController alloc] init];
        [_navigationContainer addSubview:_navigationVC.view];
        [_navigationVC.view makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_navigationContainer);
        }];

        [_navigationVC setNavigationBarHidden:YES];
        [_navigationVC.navigationBar setBackgroundImage:[self imageWithColor:[UIColor JPFakeHeaderColor]] forBarMetrics:UIBarMetricsDefault];
        _navigationVC.navigationBar.shadowImage = [UIImage new];

        _rootVC = [[JPPopupMenuRootViewController alloc] init];
        [_navigationVC setViewControllers:@[_rootVC]];

    }

    return self;
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self dismissMenu];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Menu show / dismiss
- (void)showMenuAtRefPoint:(CGPoint)point track:(SPTPartialTrack *)track {
    _track = track;
    _headerView.track = track;
    _rootVC.track = track;

    CGFloat y = point.y - [UIScreen mainScreen].bounds.size.height / 2.f;

    [self.view updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(JPTrackHeaderHeight));
        make.centerY.equalTo(_backgroundContainerView.centerY).offset(y).priorityLow();
    }];

    [_navigationContainer remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [_backgroundContainerView layoutIfNeeded];

    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(360.f));
        }];

        [_navigationContainer remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.bottom);
            make.bottom.left.right.equalTo(self.view);
        }];
        [_backgroundContainerView layoutIfNeeded];
    }];

    _backgroundContainerView.hidden = NO;
}

- (void)dismissMenu {
    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(JPTrackHeaderHeight));
        }];

        [_navigationContainer remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [_backgroundContainerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        _backgroundContainerView.hidden = YES;
//        [_actionTableView deselectRowAtIndexPath:_selectedIndexPath animated:NO];

        [_navigationVC popToRootViewControllerAnimated:NO];
    }];
}

@end

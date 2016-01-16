//
//  JPViewController.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPViewController.h"
#import "Constants.h"
#import "JPLeftBarView.h"
#import "JPPlayerView.h"
#import "JPPopupPlayerViewController.h"
#import "JPListViewController.h"

#import "TestViewController.h"

@interface JPViewController()

@property (strong, nonatomic) UIView *rightContainerView;
@property (strong, nonatomic) JPPopupPlayerViewController *popupPlayerViewController;
@property (strong, nonatomic) NSMutableArray *childViewControllers;

@property BOOL pop;

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pop = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePop:) name:@"popup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePop:) name:@"pushdown" object:nil];
    
    JPLeftBarView *leftBarView = [[JPLeftBarView alloc] init];
    [leftBarView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:leftBarView];
    
    _rightContainerView = [[UIView alloc] init];
    [self.view addSubview:_rightContainerView];
    
    JPPlayerView *playerView = [[JPPlayerView alloc] init];
    [self.view addSubview:playerView];
    
    _popupPlayerViewController = [[JPPopupPlayerViewController alloc] init];
    [self.view addSubview:_popupPlayerViewController.view];
    
    [leftBarView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.width.equalTo(@(LeftBarWidth));
    }];
    
    [playerView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.view);
        make.left.equalTo(leftBarView.right);
        make.height.equalTo(@(PlayerViewHeight));
    }];
    
    [_rightContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.bottom.equalTo(playerView.top);
        make.right.equalTo(self.view);
        make.left.equalTo(leftBarView.right);
    }];
    
    [_popupPlayerViewController.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.bottom);
        make.left.equalTo(self.view.left);
        make.size.equalTo(self.view);
    }];
    
    
    /*******************************/
    // Setup child viewcontrollers //
    /*******************************/
    _childViewControllers = [[NSMutableArray alloc] init];
    
    // settings tab
    UIButton *settingsTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [settingsTab setImage:[UIImage imageNamed:@"ic_settings_white_48pt"] forState:UIControlStateNormal];
    [leftBarView addTab:settingsTab];
    
    TestViewController *testVC1 = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC1.view];
    [_childViewControllers addObject:testVC1];
    
    // list tab
    UIButton *listTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [listTab setImage:[UIImage imageNamed:@"ic_view_list_white_48pt"] forState:UIControlStateNormal];
    [leftBarView addTab:listTab];
    
    JPListViewController *JPListVC = [[JPListViewController alloc] init];
    [_rightContainerView addSubview:JPListVC.view];
    [_childViewControllers addObject:JPListVC];
    [JPListVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_rightContainerView);
    }];
    
    // test tab
    UIButton *testTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [testTab setBackgroundColor:[UIColor darkGrayColor]];
    testTab.layer.cornerRadius = 10;
    [leftBarView addTab:testTab];
    
    TestViewController *testVC = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC.view];
    [_childViewControllers addObject:testVC];
    
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swithTab:) name:@"swithTab" object:nil];
    
    // default tab
    [[NSNotificationCenter defaultCenter] postNotificationName:@"swithTab" object:nil userInfo:@{@"tab" : @(1)}];
}

- (void)swithTab:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"tab"] integerValue];
    UIViewController *vc = [_childViewControllers objectAtIndex:index];
    [_rightContainerView bringSubviewToFront:vc.view];
}

- (void)togglePop:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"popup"]) {
        _pop = YES;
    }
    if ([notification.name isEqualToString:@"pushdown"]) {
        _pop = NO;
    }

    [UIView animateWithDuration:AnimationInterval animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return _pop;
}

@end

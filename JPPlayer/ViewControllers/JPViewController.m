//
//  JPViewController.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPViewController.h"
#import "JPLeftBarView.h"
#import "JPPlayerView.h"
#import "JPPopupPlayerViewController.h"

#import "JPTabViewController.h"
#import "JPContainerViewController.h"

#import "JPSettingsViewController.h"
#import "JPSearchViewController.h"
#import "JPBrowseViewController.h"
#import "JPListViewController.h"

#import "TestViewController.h"

@interface JPViewController()

@property (strong, nonatomic) UIView *rightContainerView;
@property (strong, nonatomic) JPPopupPlayerViewController *popupPlayerViewController;
@property (strong, nonatomic) NSMutableArray *childViewControllers;
@property (strong, nonatomic) JPTabViewController *activeTab;

@property BOOL pop;

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor JPBackgroundColor];
    
    _pop = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePop:) name:@"popup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(togglePop:) name:@"pushdown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swithTab:) name:@"switchTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addContainer:) name:@"newContainer" object:nil];
    
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
        make.left.equalTo(leftBarView.right);
        make.right.equalTo(self.view);
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
    
    JPSettingsViewController *JPSettingsVC = [[JPSettingsViewController alloc] init];
    [_rightContainerView addSubview:JPSettingsVC.view];
    [_childViewControllers addObject:JPSettingsVC];
    [JPSettingsVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_rightContainerView);
    }];

    // search tab
    UIButton *searchtab = [UIButton buttonWithType:UIButtonTypeSystem];
    [searchtab setImage:[UIImage imageNamed:@"ic_search_white_48pt"] forState:UIControlStateNormal];
    [leftBarView addTab:searchtab];

    JPSearchViewController *JPSearchVC = [[JPSearchViewController alloc] init];
    [_rightContainerView addSubview:JPSearchVC.view];
    [_childViewControllers addObject:JPSearchVC];
    [JPSearchVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_rightContainerView);
    }];

    // feature lists tab
    UIButton *featureTab = [UIButton buttonWithType:UIButtonTypeSystem];
    [featureTab setImage:[UIImage imageNamed:@"ic_stars_white_48pt"] forState:UIControlStateNormal];
    [leftBarView addTab:featureTab];

    JPBrowseViewController *JPBrowseVC = [[JPBrowseViewController alloc] init];
    [_rightContainerView addSubview:JPBrowseVC.view];
    [_childViewControllers addObject:JPBrowseVC];
    [JPBrowseVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_rightContainerView);
    }];

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

    for (NSUInteger i=0; i<5; ++i) {
        // test tab
        UIButton *testTab = [UIButton buttonWithType:UIButtonTypeSystem];
        [testTab setBackgroundColor:[UIColor darkGrayColor]];
        testTab.layer.cornerRadius = 10;
        [leftBarView addTab:testTab];
        
        TestViewController *testVC = [[TestViewController alloc] init];
        [_rightContainerView addSubview:testVC.view];
        [_childViewControllers addObject:testVC];
    }

    // default tab
    [[NSNotificationCenter defaultCenter] postNotificationName:@"switchTab" object:nil userInfo:@{@"tab" : @(3)}];
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

- (void)swithTab:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"tab"] integerValue];
    JPTabViewController *vc = [_childViewControllers objectAtIndex:index];
    [_rightContainerView bringSubviewToFront:vc.view];
    [vc viewWillAppear:YES];
    _activeTab = vc;
}

- (void)addContainer:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    JPContainerViewController *container = userInfo[@"container"];
    [_activeTab addOneContainer:container];
}

- (BOOL)prefersStatusBarHidden {
    return _pop;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

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

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JPLeftBarView *leftBarView = [[JPLeftBarView alloc] init];
    [leftBarView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:leftBarView];
    
    _rightContainerView = [[UIView alloc] init];
    [self.view addSubview:_rightContainerView];
    
    JPPlayerView *playerView = [[JPPlayerView alloc] init];
    [playerView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:playerView];
    
    _popupPlayerViewController = [[JPPopupPlayerViewController alloc] init];
    [_popupPlayerViewController.view setBackgroundColor:[UIColor lightGrayColor]];
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
    CGRect childFrame = CGRectMake(0, 0, _rightContainerView.frame.size.width, _rightContainerView.frame.size.height);
    
    // list tab
    CGFloat L = LeftBarWidth - 16;
    UIView *listTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [listTab setBackgroundColor:[UIColor lightGrayColor]];
    listTab.layer.cornerRadius = 10;
    [leftBarView addTab:listTab];
    
    JPListViewController *JPListVC = [[JPListViewController alloc] init];
    [_rightContainerView addSubview:JPListVC.view];
    [JPListVC.view setFrame:childFrame];
    [_childViewControllers addObject:JPListVC];
    
    // test tab
    UIView *testTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [testTab setBackgroundColor:[UIColor grayColor]];
    testTab.layer.cornerRadius = 10;
    [leftBarView addTab:testTab];
    
    TestViewController *testVC1 = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC1.view];
    [testVC1.view setFrame:childFrame];
    [_childViewControllers addObject:testVC1];
    
    // test tab 2
    UIView *testTab2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [testTab2 setBackgroundColor:[UIColor darkGrayColor]];
    testTab2.layer.cornerRadius = 10;
    [leftBarView addTab:testTab2];
    
    TestViewController *testVC2 = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC2.view];
    [testVC2.view setFrame:childFrame];
    [_childViewControllers addObject:testVC2];
    
    // default tab
    [JPListVC didMoveToParentViewController:self];
    [_rightContainerView bringSubviewToFront:JPListVC.view];
    
    // register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swithTab:) name:@"swithTab" object:nil];
}

- (void)swithTab:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"tab"] integerValue];
    UIViewController *vc = [_childViewControllers objectAtIndex:index];
    [_rightContainerView bringSubviewToFront:vc.view];
}

@end

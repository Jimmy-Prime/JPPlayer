//
//  JPListTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPListTableViewController.h"

@interface JPListTableViewController ()

@property (strong, nonatomic) UIImageView *blurBackgroundImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@end

@implementation JPListTableViewController
@synthesize topView = _topView;
@synthesize topViewHeight = _topViewHeight;
@synthesize list = _list;
@synthesize fakeHeaderView = _fakeHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _topView = super.topView;
    _topViewHeight = super.topViewHeight;
    _list = super.list;
    _fakeHeaderView = super.fakeHeaderView;
    
    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover.jpg"]];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [_topView addSubview:_blurBackgroundImageView];
    [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topView);
    }];
    
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_blurBackgroundImageView addSubview:_blurEffectView];
    [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_blurBackgroundImageView);
    }];
    
    UIView *overlayView = [[UIView alloc] init];
    overlayView.layer.cornerRadius = 20.f;
    [_topView addSubview:overlayView];
    [overlayView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_blurBackgroundImageView);
        make.top.greaterThanOrEqualTo(_blurBackgroundImageView);
        make.bottom.greaterThanOrEqualTo(_topView).offset(-FakeHeaderHeight);
        make.height.equalTo(@(ContainerWidth - FakeHeaderHeight));
    }];
    
    // testing UI
    UIView *circle = [[UIView alloc] init];
    circle.backgroundColor = [UIColor blackColor];
    circle.layer.cornerRadius = 100.f;
    [overlayView addSubview:circle];
    [circle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(overlayView);
        make.width.height.equalTo(@(200.f));
    }];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Skyworld";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:24];
    title.textAlignment = NSTextAlignmentCenter;
    [overlayView addSubview:title];
    [title makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(overlayView);
        make.top.equalTo(circle.bottom).offset(8);
        make.height.equalTo(@(30));
    }];
}

@end

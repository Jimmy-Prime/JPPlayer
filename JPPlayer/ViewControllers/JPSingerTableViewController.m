//
//  JPSingerTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/18/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSingerTableViewController.h"
#import "UIImageEffects.h"

@interface JPSingerTableViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *blurBackgroundImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIView *overlayView;

@end

@implementation JPSingerTableViewController
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
    
    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImageEffects imageByApplyingDarkEffectToImage:[UIImage imageNamed:@"PlaceHolder.jpg"]]];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_topView addSubview:_blurBackgroundImageView];
    [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topView);
    }];
    
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_blurBackgroundImageView addSubview:_blurEffectView];
    [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_blurBackgroundImageView);
    }];
    
    _overlayView = [[UIView alloc] init];
    _overlayView.layer.cornerRadius = 20.f;
    [_topView addSubview:_overlayView];
    [_overlayView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_blurBackgroundImageView);
        make.top.greaterThanOrEqualTo(_blurBackgroundImageView);
        make.bottom.greaterThanOrEqualTo(_topView).offset(-FakeHeaderHeight);
        make.height.equalTo(@(ContainerWidth - FakeHeaderHeight));
    }];
    
    // testing UI
    UIView *circle = [[UIView alloc] init];
    circle.backgroundColor = [UIColor greenColor];
    circle.layer.cornerRadius = 100.f;
    [_overlayView addSubview:circle];
    [circle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(_overlayView);
        make.width.height.equalTo(@(200.f));
    }];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Skyworld";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:24];
    title.textAlignment = NSTextAlignmentCenter;
    [_overlayView addSubview:title];
    [title makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_overlayView);
        make.top.equalTo(circle.bottom).offset(8);
        make.height.equalTo(@(30));
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _topViewHeight = ContainerWidth - scrollView.contentOffset.y;
    if (_topViewHeight < FakeHeaderHeight) {
        _topViewHeight = FakeHeaderHeight;
    }
    
    if (_topViewHeight >= ContainerWidth) {
        // Lower blur radius
        CGFloat diff = _topViewHeight - ContainerWidth;
        [_blurBackgroundImageView setImage:[UIImageEffects imageByApplyingBlurToImage:[UIImage imageNamed:@"PlaceHolder.jpg"] withRadius:40.f-diff tintColor:[UIColor clearColor] saturationDeltaFactor:1.8 maskImage:nil]];
        _overlayView.alpha = 1.f - diff/40.f;
    }
    
    [_topView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(_topViewHeight));
    }];
}

@end

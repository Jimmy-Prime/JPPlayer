//
//  JPPopupPlayerViewController.m
//  JPPlayer
//
//  Created by Prime on 1/8/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPPopupPlayerViewController.h"
#import "JPPopupControlViewController.h"
#import "JPCoverScrollViewController.h"
#import "JPSpotifyPlayer.h"

@interface JPPopupPlayerViewController ()

@property (strong, nonatomic) JPCoverScrollViewController *coverViewController;
@property (strong, nonatomic) JPPopupControlViewController *controlViewController;

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIImageView *blurBackgroundImageView;

@end

@implementation JPPopupPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUp:) name:@"popup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangeToTrack:) name:SpotifyDidChangeToTrack object:nil];

    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_blurBackgroundImageView];
    [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_blurBackgroundImageView addSubview:_blurEffectView];
    [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // cover view
    _coverViewController = [[JPCoverScrollViewController alloc] init];
    [self.view addSubview:_coverViewController.view];
    
    // control view
    _controlViewController = [[JPPopupControlViewController alloc] init];
    [self.view addSubview:_controlViewController.view];
    
    // push down button
    UIButton *pushDownButton = [UIButton buttonWithType:UIButtonTypeSystem];
    pushDownButton.frame = CGRectMake(20, 20, 60, 60);
    [pushDownButton setImage:[UIImage imageNamed:@"ic_keyboard_arrow_down_white_48pt"] forState:UIControlStateNormal];
    pushDownButton.contentMode = UIViewContentModeScaleToFill;
    pushDownButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    pushDownButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    pushDownButton.tintColor = [UIColor JPColor];
    [self.view addSubview:pushDownButton];
    [pushDownButton addTarget:self action:@selector(pushDown:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat width, height, longer, shorter;
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    longer = width>height ? width : height;
    shorter = width>height ? height : width;
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            _coverViewController.landscape = YES;
            [_coverViewController.view updateConstraints:^(MASConstraintMaker *make) {
                CGFloat interval = (shorter - CoverLength - 2.f * CoverInset) / 2.f;
                make.top.equalTo(self.view).offset(interval / 2.f + CoverInset);
                make.right.equalTo(self.view).offset(-55.f);
                make.height.equalTo(@(CoverLength + interval));
                make.width.equalTo(@(CoverLength));
            }];
            
            _controlViewController.landscape = YES;
            [_controlViewController.view updateConstraints:^(MASConstraintMaker *make) {
                CGFloat heightOffset = 200.f;
                CGFloat widthOffset = 40.f;
                make.bottom.equalTo(self.view).offset(-heightOffset);
                make.left.equalTo(self.view).offset(widthOffset);
                make.height.equalTo(@(shorter - 2*heightOffset));
                make.width.equalTo(@(longer - CoverLength - 2*widthOffset - 55.f));
            }];
            break;
        }
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            _coverViewController.landscape = NO;
            [_coverViewController.view updateConstraints:^(MASConstraintMaker *make) {
                CGFloat interval = (shorter - CoverLength - 2.f * CoverInset) / 2.f;
                make.top.equalTo(self.view).offset(90);
                make.right.equalTo(self.view).offset(-interval / 2.f - CoverInset);
                make.height.equalTo(@(CoverLength));
                make.width.equalTo(@(CoverLength + interval));
            }];
            
            _controlViewController.landscape = NO;
            [_controlViewController.view updateConstraints:^(MASConstraintMaker *make) {
                CGFloat widthOffset = 84.f;
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view).offset(widthOffset);
                make.height.equalTo(@(longer - CoverLength - 90));
                make.width.equalTo(@(shorter - 2.f * widthOffset));
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)popUp:(NSNotification *)notification {
    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view.superview);
        }];
        [self.view.superview layoutIfNeeded];
    }];
}

- (void)pushDown:(UIButton *)button {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushdown" object:nil];
    
    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.superview.bottom);
            make.left.equalTo(self.view.superview.left);
            make.size.equalTo(self.view.superview);
        }];
        [self.view.superview layoutIfNeeded];
    }];
}

- (void)spotifyDidChangeToTrack:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    SPTTrack *track = [userInfo objectForKey:@"track"];
    [_blurBackgroundImageView setImageWithURL:[[[track album] largestCover] imageURL]];
}

@end

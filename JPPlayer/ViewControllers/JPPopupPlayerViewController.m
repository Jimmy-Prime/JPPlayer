//
//  JPPopupPlayerViewController.m
//  JPPlayer
//
//  Created by Prime on 1/8/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPPopupPlayerViewController.h"
#import "JPCoverScrollViewController.h"
#import "Constants.h"

@interface JPPopupPlayerViewController ()

@property (strong, nonatomic) JPCoverScrollViewController *coverViewController;
@property (strong, nonatomic) UIView *controlView;

@end

@implementation JPPopupPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUp:) name:@"popup" object:nil];
    
    // cover view
    _coverViewController = [[JPCoverScrollViewController alloc] init];
    [self.view addSubview:_coverViewController.view];
    
    // control view
    _controlView = [[UIView alloc] init];
    [self.view addSubview:_controlView];
    _controlView.backgroundColor = [UIColor grayColor];
    
    // push down button
    UIButton *pushDownButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    pushDownButton.backgroundColor = [UIColor darkGrayColor];
    pushDownButton.layer.cornerRadius = 10.f;
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
                make.top.equalTo(self.view);
                make.right.equalTo(self.view).offset(-55);
                make.height.equalTo(@(shorter));
                make.width.equalTo(@(600));
            }];
            
            [_controlView updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view);
                make.height.equalTo(@(shorter));
                make.width.equalTo(@(longer - 600 - 55));
            }];
            break;
        }
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            _coverViewController.landscape = NO;
            [_coverViewController.view updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(90);
                make.right.equalTo(self.view);
                make.height.equalTo(@(600));
                make.width.equalTo(@(shorter));
            }];
            
            [_controlView updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view);
                make.height.equalTo(@(longer - 600 - 90));
                make.width.equalTo(@(shorter));
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
    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.superview.bottom);
            make.left.equalTo(self.view.superview.left);
            make.size.equalTo(self.view.superview);
        }];
        [self.view.superview layoutIfNeeded];
    }];
}


@end

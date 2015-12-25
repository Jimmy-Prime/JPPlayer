//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPListViewController.h"
#import "Constants.h"
#import "JPContainerViewController.h"

@interface JPListViewController ()

@property (strong, nonatomic) UIView *propView;

@end

@implementation JPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _propView = [[UIView alloc] init];
    [_propView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:_propView];
    [_propView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    JPContainerViewController *container = [[JPContainerViewController alloc] init];
    [self.view addSubview:container.view];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [container.view addGestureRecognizer:pan];
    
    [container.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.view);
        make.width.equalTo(@(ContainerWidth));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [container.view addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    view.tag = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [view remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self.view);
            make.width.equalTo(@(ContainerWidth));
        }];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        JPContainerViewController *container = [[JPContainerViewController alloc] init];
        [self.view addSubview:container.view];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [container.view addGestureRecognizer:pan];
        
        [container.view makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.view);
            make.width.equalTo(@500);
        }];
        
        [container.view addGestureRecognizer:tap];
    }];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    CGPoint move = [pan translationInView:view];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 animations:^{
            [view remakeConstraints:^(MASConstraintMaker *make) {
                if (view.center.x < view.superview.center.x) {
                    make.left.equalTo(self.view);
                    view.tag = 0;
                }
                else {
                    make.right.equalTo(self.view);
                    view.tag = 1;
                }
                make.top.bottom.equalTo(self.view);
                make.width.equalTo(@500);
            }];
            [self.view layoutIfNeeded];
        }];
        
        return;
    }
    
    [view remakeConstraints:^(MASConstraintMaker *make) {
        if (view.tag) {
            make.right.equalTo(self.view).offset(move.x).priorityLow();
        }
        else {
            make.left.equalTo(self.view).offset(move.x).priorityLow();
        }
        make.left.greaterThanOrEqualTo(self.view).priorityHigh();
        make.right.lessThanOrEqualTo(self.view).priorityHigh();
        make.top.bottom.equalTo(self.view);
        make.width.equalTo(@500);
    }];
}

@end

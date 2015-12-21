//
//  JPLeftBarView.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPLeftBarView.h"

@interface JPLeftBarView()

@property NSUInteger tabCount;
@property (strong, nonatomic) UIView *lastView;

@end

@implementation JPLeftBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        _tabCount = 0;
    }
    return self;
}

- (void)addTab:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    
    CGFloat height = view.frame.size.height;
    
    if (_lastView) {
        [view makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_lastView.bottom).offset(8);
            make.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.height.equalTo(@(height));
        }];
    }
    else {
        [view makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.height.equalTo(@(height));
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [view addGestureRecognizer:tap];
    [view setTag:_tabCount];
    
    _lastView = view;
    _tabCount++;
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"swithTab" object:nil userInfo:@{@"tab" : @(tap.view.tag)}];
}

@end

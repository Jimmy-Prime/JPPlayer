//
//  JPPlayerView.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPPlayerView.h"

@interface JPPlayerView()

@property BOOL popped;

@end

@implementation JPPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        _popped = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePopped:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)togglePopped:(UITapGestureRecognizer *)tap {
    UIView *superview = self.superview;
    
    [UIView animateWithDuration:0.3 animations:^{
        _popped = !_popped;
        if (_popped) {
            [superview removeConstraints:_normalConstraints];
            [superview addConstraints:_popupConstraints];
        }
        else {
            [superview removeConstraints:_popupConstraints];
            [superview addConstraints:_normalConstraints];
        }
        [superview layoutIfNeeded];
    }];
}

@end

//
//  JPPopupPlayerView.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPPopupPlayerView.h"

@implementation JPPopupPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUp:) name:@"popup" object:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDown:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)popUp:(NSNotification *)notification {
    UIView *superview = self.superview;
    CGRect frame = superview.frame;
    frame.origin.y = frame.size.height;
    [self setFrame:frame];
    
    [UIView animateWithDuration:0.3 animations:^{
        [superview addConstraints:_constraints];
        [superview layoutIfNeeded];
    }];
}

- (void)pushDown:(UITapGestureRecognizer *)tap {
    UIView *superview = self.superview;
    [superview removeConstraints:_constraints];
    [superview layoutIfNeeded];
    
    [self setFrame:superview.frame];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = superview.frame;
        frame.origin.y = frame.size.height;
        [self setFrame:frame];
    }];
}

@end

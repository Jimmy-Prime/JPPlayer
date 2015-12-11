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
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *superview = self.superview;
    CGRect frame = superview.frame;
    frame.origin.y = frame.size.height;
    [self setFrame:frame];
    
    [superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        [superview addConstraints:_constraints];
        [superview layoutIfNeeded];
    }];
}

- (void)pushDown:(UITapGestureRecognizer *)tap {
    UIView *superview = self.superview;
    [UIView animateWithDuration:0.3 animations:^{
        [superview removeConstraints:_constraints];
        [superview layoutIfNeeded];
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        CGRect frame = superview.frame;
        frame.origin.y = frame.size.height;
        [self setFrame:frame];
    } completion:^(BOOL finished) {
        [superview sendSubviewToBack:self];
    }];
}

@end

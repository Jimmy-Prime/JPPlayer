//
//  JPPopupPlayerView.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
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
    [UIView animateWithDuration:0.3 animations:^{
        [self remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.superview);
        }];
        [self.superview layoutIfNeeded];
    }];
}

- (void)pushDown:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.3 animations:^{
        [self remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.superview.bottom);
            make.left.equalTo(self.superview.left);
            make.size.equalTo(self.superview);
        }];
        [self.superview layoutIfNeeded];
    }];
}

@end

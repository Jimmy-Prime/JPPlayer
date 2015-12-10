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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"popup" object:nil];
}

@end

//
//  JPLeftBarView.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPLeftBarView.h"

@implementation JPLeftBarView

+ (instancetype)view {
    static JPLeftBarView *sharedView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[self alloc] init];
    });
    return sharedView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

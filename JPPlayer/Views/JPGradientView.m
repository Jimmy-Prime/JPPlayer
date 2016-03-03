//
//  JPGradientView.m
//  JPPlayer
//
//  Created by Prime on 3/3/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPGradientView.h"

@interface JPGradientView()

@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation JPGradientView

- (instancetype)init {
    self = [super init];
    if (self) {
        _gradient = [CAGradientLayer layer];
        _gradient.startPoint = (CGPoint){0.f, 0.5f};
        _gradient.endPoint = (CGPoint){1.f, 0.5f};
        [self.layer insertSublayer:_gradient atIndex:0];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _gradient.frame = self.bounds;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    _gradient.colors = @[(id)[color CGColor], (id)[[UIColor blackColor] CGColor]];
}

@end

//
//  JPLeftBarView.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

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
    
    // set auto layout constraints
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(view)]];
    
    if (_lastView) {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_lastView]-[view(%lf)]", height]
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(_lastView, view)]];
    }
    else {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[view(%lf)]", height]
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(view)]];
    }
    
    [self addConstraints:constraints];
    
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

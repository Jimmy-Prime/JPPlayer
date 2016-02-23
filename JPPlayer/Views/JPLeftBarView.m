//
//  JPLeftBarView.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPLeftBarView.h"

@interface JPLeftBarView()

@property (strong, nonatomic) NSMutableArray *tabs;
@property NSUInteger lastIndex;
@property (strong, nonatomic) UIView *indicator;

@end

@implementation JPLeftBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        _tabs = [[NSMutableArray alloc] init];
        _lastIndex = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swithTab:) name:@"swithTab" object:nil];
        
        _indicator = [[UIView alloc] init];
        [self addSubview:_indicator];
        _indicator.backgroundColor = [UIColor JPColor];
        [_indicator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.equalTo(@(5));
            make.height.equalTo(@(LeftBarWidth - 10));
        }];
    }
    return self;
}

- (void)addTab:(UIButton *)tab {
    tab.tintColor = [UIColor whiteColor];
    tab.contentMode = UIViewContentModeScaleToFill;
    tab.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    tab.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    [self addSubview:tab];
        
    if (_tabs.count) {
        [tab makeConstraints:^(MASConstraintMaker *make) {
            UIButton *lastTab = [_tabs lastObject];
            make.top.equalTo(lastTab.bottom).offset(8);
            make.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.height.equalTo(tab.width);
        }];
    }
    else {
        [tab makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.height.equalTo(tab.width);
        }];
    }
    
    [tab addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [tab setTag:_tabs.count];
    [_tabs addObject:tab];
}

- (void)tapped:(UIButton *)tab {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"swithTab" object:nil userInfo:@{@"tab" : @(tab.tag)}];
}

- (void)swithTab:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"tab"] integerValue];
    [_indicator updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset((LeftBarWidth-8) * index + 5);
    }];
    
    UIButton *tab = [_tabs objectAtIndex:_lastIndex];
    tab.tintColor = [UIColor whiteColor];
    tab = [_tabs objectAtIndex:index];
    tab.tintColor = [UIColor JPColor];
    _lastIndex = index;
}

@end

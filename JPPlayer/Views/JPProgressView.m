//
//  JPProgressView.m
//  JPPlayer
//
//  Created by Prime on 1/11/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPProgressView.h"
#import "Constants.h"

@interface JPProgressView()

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *atTimeLabel;
@property (strong, nonatomic) UIButton *auxTimeButton;

@end

@implementation JPProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        _atTimeLabel = [[UILabel alloc] init];
        [self addSubview:_atTimeLabel];
        _atTimeLabel.text = @"01:27";
        _atTimeLabel.textColor = [UIColor whiteColor];
        _atTimeLabel.textAlignment = NSTextAlignmentCenter;
        _atTimeLabel.font = [UIFont systemFontOfSize:10];
        [_atTimeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.equalTo(@(TimeLabelWidth));
        }];
        
        _auxTimeButton = [[UIButton alloc] init];
        [self addSubview:_auxTimeButton];
        [_auxTimeButton setTitle:@"04:18" forState:UIControlStateNormal];
        [_auxTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _auxTimeButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_auxTimeButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(@(TimeLabelWidth));
        }];
        
        _slider = [[UISlider alloc] init];
        [self addSubview:_slider];
        _slider.maximumValue = 100.f;
        _slider.minimumValue = 0.f;
        _slider.value = 37.f;
        [_slider makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(_atTimeLabel.right);
            make.right.equalTo(_auxTimeButton.left);
        }];
    }
    
    return self;
}

@end

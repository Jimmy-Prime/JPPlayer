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
@property (strong, nonatomic) UILabel *timeIndicator;
@property (strong, nonatomic) UILabel *atTimeLabel;
@property (strong, nonatomic) UIButton *auxTimeButton;

@property NSUInteger atTime;
@property NSUInteger totalTime;

@end

@implementation JPProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        _atTime = 87;
        _totalTime = 258;
        
        _atTimeLabel = [[UILabel alloc] init];
        [self addSubview:_atTimeLabel];
        _atTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", _atTime/60, _atTime%60];
        _atTimeLabel.textColor = [UIColor whiteColor];
        _atTimeLabel.textAlignment = NSTextAlignmentCenter;
        _atTimeLabel.font = [UIFont systemFontOfSize:10];
        [_atTimeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.equalTo(@(TimeLabelWidth));
        }];
        
        _auxTimeButton = [[UIButton alloc] init];
        [self addSubview:_auxTimeButton];
        NSString *totalTimeString = [NSString stringWithFormat:@"%02lu:%02lu", _totalTime/60, _totalTime%60];
        [_auxTimeButton setTitle:totalTimeString forState:UIControlStateNormal];
        [_auxTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _auxTimeButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_auxTimeButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(@(TimeLabelWidth));
        }];
        
        _timeIndicator = [[UILabel alloc] init];
        [self addSubview:_timeIndicator];
        _timeIndicator.backgroundColor = [UIColor whiteColor];
        _timeIndicator.textAlignment = NSTextAlignmentCenter;
        _timeIndicator.clipsToBounds = YES;
        _timeIndicator.layer.cornerRadius = 10.f;
        _timeIndicator.hidden = YES;
        
        _slider = [[UISlider alloc] init];
        [self addSubview:_slider];
        _slider.maximumValue = _totalTime;
        _slider.minimumValue = 0;
        _slider.value = _atTime;
        _slider.tintColor = [UIColor redColor];
        [_slider setThumbImage:[UIImage imageNamed:@"ic_fiber_manual_record_white_18pt"] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderRelease:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_slider makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(_atTimeLabel.right);
            make.right.equalTo(_auxTimeButton.left);
        }];
    }
    
    return self;
}

- (void)sliderValueChanged:(UISlider *)slider {
    _atTime = floorf(slider.value + 0.5);
    _atTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", _atTime/60, _atTime%60];
    
    [_timeIndicator remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_slider.top).offset(-10);
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.centerX.equalTo(@(CGRectGetWidth(slider.frame) * (slider.value/(float)_totalTime - 0.5)));
    }];
    _timeIndicator.text = _atTimeLabel.text;
    _timeIndicator.hidden = NO;
}

- (void)sliderRelease:(UISlider *)slider {
    _timeIndicator.hidden = YES;
}

@end

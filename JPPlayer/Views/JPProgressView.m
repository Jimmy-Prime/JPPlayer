//
//  JPProgressView.m
//  JPPlayer
//
//  Created by Prime on 1/11/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPProgressView.h"
#import "JPSpotifyPlayer.h"

@interface JPProgressView()

@property (nonatomic) BOOL seeking;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *timeIndicator;
@property (strong, nonatomic) UILabel *atTimeLabel;
@property (strong, nonatomic) UIButton *auxTimeButton;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger atTime;
@property (nonatomic) NSUInteger totalTime;

@end

@implementation JPProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        _seeking = NO;
        
        _atTimeLabel = [[UILabel alloc] init];
        [self addSubview:_atTimeLabel];
        _atTimeLabel.textColor = [UIColor whiteColor];
        _atTimeLabel.textAlignment = NSTextAlignmentCenter;
        _atTimeLabel.font = [UIFont systemFontOfSize:10];
        [_atTimeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.equalTo(@(TimeLabelWidth));
        }];
        
        _auxTimeButton = [[UIButton alloc] init];
        [self addSubview:_auxTimeButton];
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
    _seeking = YES;
    
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
    _seeking = NO;
    _timeIndicator.hidden = YES;
    
    self.atTime = _atTime;
    [[JPSpotifyPlayer playerWithCliendId:[[SPTAuth defaultInstance] clientID]] seekToOffset:_atTime callback:nil];
}

- (void)setAtTime:(NSUInteger)atTime {
    _atTime = atTime;
    
    if (_atTimeLabel) {
        _atTimeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", _atTime/60, _atTime%60];
    }
    
    if (_slider) {
        _slider.value = _atTime;
    }
}

- (void)setTotalTime:(NSUInteger)totalTime {
    _totalTime = totalTime;
    
    if (_auxTimeButton) {
        NSString *totalTimeString = [NSString stringWithFormat:@"%02lu:%02lu", _totalTime/60, _totalTime%60];
        [_auxTimeButton setTitle:totalTimeString forState:UIControlStateNormal];
    }
    
    if (_slider) {
        _slider.maximumValue = _totalTime;
    }
}

- (void)resetDuration:(NSTimeInterval)duration {
    self.atTime = 0;
    self.totalTime = (NSUInteger)duration;
}

- (void)timerAccumulate {
    if (_slider && !_seeking) {
        self.atTime++;
    }
}

- (void)updateStatus:(BOOL)isPlaying {
    if (isPlaying) {
        if (_timer) {
            [_timer invalidate];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAccumulate) userInfo:nil repeats:YES];
        [_timer fire];
    }
    else {
        [_timer invalidate];
    }
}

@end

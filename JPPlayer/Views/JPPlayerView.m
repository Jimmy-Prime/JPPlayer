//
//  JPPlayerView.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPPlayerView.h"
#import "Constants.h"
#import "JPTrackLabel.h"
#import "JPProgressView.h"

@interface JPPlayerView()

@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIImageView *blurBackgroundImageView;

@end

@implementation JPPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover.jpg"]];
        _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_blurBackgroundImageView];
        [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_blurBackgroundImageView addSubview:_blurEffectView];
        [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        // popup container
        UIView *popupButtonContainer = [[UIView alloc] init];
        [self addSubview:popupButtonContainer];
        [popupButtonContainer makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.equalTo(@(5 + SmallButtonWidth + 5 + LargeButtonWidth + 5));
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popup:)];
        [popupButtonContainer addGestureRecognizer:tap];
        
        UIImageView *upIndicator = [[UIImageView alloc] init];
        [popupButtonContainer addSubview:upIndicator];
        [upIndicator setImage:[[UIImage imageNamed:@"ic_keyboard_arrow_up_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        upIndicator.contentMode = UIViewContentModeScaleToFill;
        upIndicator.tintColor = [UIColor redColor];
        [upIndicator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(popupButtonContainer).offset(5);
            make.centerY.equalTo(popupButtonContainer);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];
        
        UIImageView *coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover.jpg"]];
        [popupButtonContainer addSubview:coverImageView];
        coverImageView.contentMode = UIViewContentModeScaleToFill;
        [coverImageView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(popupButtonContainer).offset(-5);
            make.centerY.equalTo(popupButtonContainer);
            make.width.height.equalTo(@(LargeButtonWidth));
        }];
        
        // player controler
        UIView *controlContainer = [[UIView alloc] init];
        [self addSubview:controlContainer];
        [controlContainer makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(@(SmallButtonWidth * 3 + LargeButtonWidth + 25));
        }];
        
        UIButton *volumeControlButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [controlContainer addSubview:volumeControlButton];
        [volumeControlButton setImage:[UIImage imageNamed:@"ic_volume_down_white_48pt"] forState:UIControlStateNormal];
        volumeControlButton.contentMode = UIViewContentModeScaleAspectFit;
        volumeControlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        volumeControlButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        volumeControlButton.tintColor = [UIColor redColor];
        [volumeControlButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(controlContainer).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];
        
        UIButton *skipPrevButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [controlContainer addSubview:skipPrevButton];
        [skipPrevButton setImage:[UIImage imageNamed:@"ic_skip_previous_white_48pt"] forState:UIControlStateNormal];
        skipPrevButton.contentMode = UIViewContentModeScaleAspectFit;
        skipPrevButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        skipPrevButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        skipPrevButton.tintColor = [UIColor redColor];
        [skipPrevButton addTarget:self action:@selector(skipPrev:) forControlEvents:UIControlEventTouchUpInside];
        [skipPrevButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(volumeControlButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];
        
        UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [controlContainer addSubview:playPauseButton];
        [playPauseButton setImage:[UIImage imageNamed:@"ic_play_circle_outline_white_48pt"] forState:UIControlStateNormal];
        playPauseButton.contentMode = UIViewContentModeScaleAspectFit;
        playPauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        playPauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        playPauseButton.tintColor = [UIColor redColor];
        [playPauseButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [playPauseButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(skipPrevButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(LargeButtonWidth));
        }];
        
        UIButton *skipNextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [controlContainer addSubview:skipNextButton];
        [skipNextButton setImage:[UIImage imageNamed:@"ic_skip_next_white_48pt"] forState:UIControlStateNormal];
        skipNextButton.contentMode = UIViewContentModeScaleAspectFit;
        skipNextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        skipNextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        skipNextButton.tintColor = [UIColor redColor];
        [skipNextButton addTarget:self action:@selector(skipNext:) forControlEvents:UIControlEventTouchUpInside];
        [skipNextButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(playPauseButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];
        
        // caption label
        JPTrackLabel *trackLabel = [[JPTrackLabel alloc] initWithType:JPTrackLabelTypeTrackAndSinger];
        [self addSubview:trackLabel];
        [trackLabel setWithStrings:@[@"Good Life", @"OneRepublic"]];
        [trackLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(popupButtonContainer.right);
            make.right.equalTo(controlContainer.left);
            make.height.equalTo(@(PlayerViewHeight * .5f));
        }];
        
        // progress view
        JPProgressView *progressView = [[JPProgressView alloc] init];
        [self addSubview:progressView];
        [progressView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(popupButtonContainer.right);
            make.right.equalTo(controlContainer.left);
            make.height.equalTo(@(PlayerViewHeight * .5f));
        }];
    }
    
    return self;
}

- (void)popup:(UITapGestureRecognizer *)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"popup" object:nil];
}

- (void)skipPrev:(UIButton *)button {
    NSLog(@"Prev");
}

- (void)play:(UIButton *)button {
    NSLog(@"Play");
}

- (void)skipNext:(UIButton *)button {
    NSLog(@"Next");
}

@end

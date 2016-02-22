//
//  JPPlayerView.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPPlayerView.h"
#import "JPTrackLabel.h"
#import "JPProgressView.h"
#import "JPSpotifyPlayer.h"

@interface JPPlayerView()

@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIImageView *blurBackgroundImageView;

@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) JPTrackLabel *trackLabel;
@property (strong, nonatomic) JPProgressView *progressView;

@end

@implementation JPPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangeToTrack:) name:SpotifyDidChangeToTrack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangePlaybackStatus:) name:SpotifyDidChangePlaybackStatus object:nil];
        
        _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
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
        
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
        [popupButtonContainer addSubview:_coverImageView];
        _coverImageView.contentMode = UIViewContentModeScaleToFill;
        [_coverImageView makeConstraints:^(MASConstraintMaker *make) {
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
        
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [controlContainer addSubview:_playPauseButton];
        [_playPauseButton setImage:[UIImage imageNamed:@"ic_play_circle_outline_white_48pt"] forState:UIControlStateNormal];
        _playPauseButton.contentMode = UIViewContentModeScaleAspectFit;
        _playPauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _playPauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _playPauseButton.tintColor = [UIColor redColor];
        [_playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
        [_playPauseButton makeConstraints:^(MASConstraintMaker *make) {
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
            make.left.equalTo(_playPauseButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];
        
        // caption label
        _trackLabel = [[JPTrackLabel alloc] initWithType:JPTrackLabelTypeTrackAndSinger];
        [self addSubview:_trackLabel];
        [_trackLabel setWithStrings:@[@"Not Available", @"Not Available"]];
        [_trackLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(popupButtonContainer.right);
            make.right.equalTo(controlContainer.left);
            make.height.equalTo(@(PlayerViewHeight * .5f));
        }];
        
        // progress view
        _progressView = [[JPProgressView alloc] init];
        [self addSubview:_progressView];
        [_progressView makeConstraints:^(MASConstraintMaker *make) {
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

- (void)spotifyDidChangeToTrack:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    SPTTrack *track = [userInfo objectForKey:@"track"];
    
    [_blurBackgroundImageView setImageWithURL:[[[track album] largestCover] imageURL]];
    [_coverImageView setImageWithURL:[[[track album] smallestCover] imageURL]];
    
    NSTimeInterval duration = track.duration;
    [_progressView resetDuration:duration];
    
    NSString *trackName = track.name;
    NSString *artistName = [(SPTPartialArtist *)[track.artists objectAtIndex:0] name];
    [_trackLabel setWithStrings:@[trackName, artistName]];
}

- (void)spotifyDidChangePlaybackStatus:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    BOOL isPlaying = [(NSNumber *)[userInfo objectForKey:@"isPlaying"] boolValue];
        
    [_progressView updateStatus:isPlaying];
    if (isPlaying) {
        [_playPauseButton setImage:[UIImage imageNamed:@"ic_pause_circle_outline_white_48pt"] forState:UIControlStateNormal];
    }
    else {
        [_playPauseButton setImage:[UIImage imageNamed:@"ic_play_circle_outline_white_48pt"] forState:UIControlStateNormal];
    }
}

- (void)skipPrev:(UIButton *)button {
    [[JPSpotifyPlayer defaultInstance] playPrevious];
}

- (void)playPause:(UIButton *)button {
    SPTAudioStreamingController *player = [JPSpotifyPlayer player];
    [player setIsPlaying:!player.isPlaying callback:nil];
}

- (void)skipNext:(UIButton *)button {
    [[JPSpotifyPlayer defaultInstance] playNext];
}

@end

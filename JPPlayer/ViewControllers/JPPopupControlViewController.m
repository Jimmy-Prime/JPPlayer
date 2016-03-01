//
//  JPPopupControlViewController.m
//  JPPlayer
//
//  Created by Prime on 1/13/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPPopupControlViewController.h"
#import "JPTrackLabel.h"
#import "JPProgressView.h"
#import "jPSpotifyPlayer.h"

@interface JPPopupControlViewController ()

@property (strong, nonatomic) JPProgressView *progressView;
@property (strong, nonatomic) UIButton *shuffleButton;
@property (strong, nonatomic) UIButton *skipPrevButton;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UIButton *skipNextButton;
@property (strong, nonatomic) UIButton *repeatButton;
@property (strong, nonatomic) UIView *line;

@property (strong, nonatomic) JPTrackLabel *trackLabel;
@property (strong, nonatomic) JPTrackLabel *singerLabel;
@property (strong, nonatomic) JPTrackLabel *albumLabel;

@end

@implementation JPPopupControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangePlaybackStatus:) name:SpotifyDidChangePlaybackStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangeToTrack:) name:SpotifyDidChangeToTrack object:nil];
    
    CGFloat interval = 24.f;
    
    _trackLabel = [[JPTrackLabel alloc] initWithType:JPTrackLabelTypeTrackOnly];
    [self.view addSubview:_trackLabel];
    [_trackLabel setWithStrings:@[@"Not Available"]];
    [_trackLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(interval);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight / 2.f));
    }];
    
    _singerLabel = [[JPTrackLabel alloc] initWithType:JPTrackLabelTypeSingerOnly];
    [self.view addSubview:_singerLabel];
    [_singerLabel setWithStrings:@[@"Not Available"]];
    [_singerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_trackLabel.bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight / 2.f));
    }];
    
    _progressView = [[JPProgressView alloc] init];
    [self.view addSubview:_progressView];
    [_progressView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_singerLabel.bottom).offset(interval);
        make.left.width.equalTo(self.view);
        make.height.equalTo(@(40));
    }];
    
    // control container
    UIView *controlContainer = [[UIView alloc] init];
    [self.view addSubview:controlContainer];
    [controlContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_progressView.bottom).offset(interval);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayButtonWidth));
    }];
    
    _shuffleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [controlContainer addSubview:_shuffleButton];
    [_shuffleButton setImage:[UIImage imageNamed:@"ic_shuffle_white_48pt"] forState:UIControlStateNormal];
    _shuffleButton.contentMode = UIViewContentModeScaleToFill;
    _shuffleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _shuffleButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _shuffleButton.tintColor = [UIColor lightGrayColor];
    [_shuffleButton addTarget:self action:@selector(shuffle:) forControlEvents:UIControlEventTouchUpInside];
    [_shuffleButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlContainer);
        make.width.height.equalTo(@(SmallButtonWidth));
    }];
    
    _skipPrevButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [controlContainer addSubview:_skipPrevButton];
    [_skipPrevButton setImage:[UIImage imageNamed:@"ic_skip_previous_white_48pt"] forState:UIControlStateNormal];
    _skipPrevButton.contentMode = UIViewContentModeScaleToFill;
    _skipPrevButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _skipPrevButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _skipPrevButton.tintColor = [UIColor JPColor];
    [_skipPrevButton addTarget:self action:@selector(skipPrev:) forControlEvents:UIControlEventTouchUpInside];
    [_skipPrevButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlContainer);
        make.width.height.equalTo(@(LargeButtonWidth));
    }];
    
    _playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [controlContainer addSubview:_playPauseButton];
    [_playPauseButton setImage:[UIImage imageNamed:@"ic_play_circle_outline_white_48pt"] forState:UIControlStateNormal];
    _playPauseButton.contentMode = UIViewContentModeScaleToFill;
    _playPauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _playPauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _playPauseButton.tintColor = [UIColor JPColor];
    [_playPauseButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [_playPauseButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(controlContainer);
        make.width.height.equalTo(@(PlayButtonWidth));
    }];
    
    _skipNextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [controlContainer addSubview:_skipNextButton];
    [_skipNextButton setImage:[UIImage imageNamed:@"ic_skip_next_white_48pt"] forState:UIControlStateNormal];
    _skipNextButton.contentMode = UIViewContentModeScaleToFill;
    _skipNextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _skipNextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _skipNextButton.tintColor = [UIColor JPColor];
    [_skipNextButton addTarget:self action:@selector(skipNext:) forControlEvents:UIControlEventTouchUpInside];
    [_skipNextButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlContainer);
        make.width.height.equalTo(@(LargeButtonWidth));
    }];
    
    _repeatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [controlContainer addSubview:_repeatButton];
    [_repeatButton setImage:[UIImage imageNamed:@"ic_repeat_white_48pt"] forState:UIControlStateNormal];
    _repeatButton.contentMode = UIViewContentModeScaleToFill;
    _repeatButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _repeatButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _repeatButton.tintColor = [UIColor lightGrayColor];
    [_repeatButton addTarget:self action:@selector(repeat:) forControlEvents:UIControlEventTouchUpInside];
    [_repeatButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlContainer);
        make.width.height.equalTo(@(SmallButtonWidth));
    }];
    
    // line
    _line = [[UIView alloc] init];
    [self.view addSubview:_line];
    _line.layer.borderWidth = 1.f;
    _line.layer.borderColor = [UIColor JPColor].CGColor;
    [_line makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlContainer.bottom).offset(interval);
        make.left.equalTo(self.view).offset(interval);
        make.right.equalTo(self.view).offset(-interval);
        make.height.equalTo(@(1.f));
    }];
    
    // album label
    _albumLabel = [[JPTrackLabel alloc] initWithType:JPTrackLabelTypeSingerOnly];
    [self.view addSubview:_albumLabel];
    [_albumLabel setWithStrings:@[@"Not Available"]];
    [_albumLabel makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-interval);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight));
    }];
}

- (void)viewDidLayoutSubviews {
    CGFloat controlOffset;
    if (_landscape) {
        controlOffset = 12.f;
        _line.hidden = NO;
    }
    else {
        controlOffset = 50.f;
        _line.hidden = YES;
    }
    
    [_shuffleButton updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_skipPrevButton.left).offset(-controlOffset);
    }];
    
    [_skipPrevButton updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_playPauseButton.left).offset(-controlOffset);
    }];
    
    [_skipNextButton updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playPauseButton.right).offset(controlOffset);
    }];
    
    [_repeatButton updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skipNextButton.right).offset(controlOffset);
    }];
}

- (void)spotifyDidChangeToTrack:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    SPTPlaylistTrack *track = [userInfo objectForKey:@"track"];
    
    NSTimeInterval duration = track.duration;
    [_progressView resetDuration:duration];
    
    NSString *trackName = track.name;
    [_trackLabel setWithStrings:@[trackName]];
    NSString *artistName = [(SPTPartialArtist *)[track.artists objectAtIndex:0] name];
    [_singerLabel setWithStrings:@[artistName]];
    NSString *albumName = track.album.name;
    [_albumLabel setWithStrings:@[albumName]];
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

- (void)shuffle:(UIButton *)button {
    [JPSpotifyPlayer defaultInstance].shuffle = ![JPSpotifyPlayer defaultInstance].shuffle;
    if ([JPSpotifyPlayer defaultInstance].shuffle) {
        button.tintColor = [UIColor JPColor];
    }
    else {
        button.tintColor = [UIColor lightGrayColor];
    }
    
    if ([JPSpotifyPlayer defaultInstance].shuffle) {
        button.tintColor = [UIColor JPColor];
    }
    else {
        button.tintColor = [UIColor lightGrayColor];
    }
}

- (void)skipPrev:(UIButton *)button {
    [[JPSpotifyPlayer defaultInstance] playPrevious];
}

- (void)playPause:(UIButton *)button {
    [[JPSpotifyPlayer defaultInstance] playPause];
}

- (void)skipNext:(UIButton *)button {
    [[JPSpotifyPlayer defaultInstance] playNext];
}

- (void)repeat:(UIButton *)button {
    [JPSpotifyPlayer defaultInstance].playbackState = ([JPSpotifyPlayer defaultInstance].playbackState + 1) % JPSpotifyPlaybackModeCount;
    switch ([JPSpotifyPlayer defaultInstance].playbackState) {
        case JPSpotifyPlaybackNone:
            button.tintColor = [UIColor lightGrayColor];
            [button setImage:[UIImage imageNamed:@"ic_repeat_white_48pt"] forState:UIControlStateNormal];
            break;
            
        case JPSpotifyPlaybackCycle:
            button.tintColor = [UIColor JPColor];
            [button setImage:[UIImage imageNamed:@"ic_repeat_white_48pt"] forState:UIControlStateNormal];
            break;
            
        case JPSpotifyPlaybackOne:
            button.tintColor = [UIColor JPColor];
            [button setImage:[UIImage imageNamed:@"ic_repeat_one_white_48pt"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end

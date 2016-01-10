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

@end

@implementation JPPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        // popup container
        UIView *popupButtonContainer = [[UIView alloc] init];
        [self addSubview:popupButtonContainer];
        [popupButtonContainer makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.equalTo(@(PlayerViewHeight + ButtonWidth + 5));
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popup:)];
        [popupButtonContainer addGestureRecognizer:tap];
        
        UIImageView *upIndicator = [[UIImageView alloc] init];
        [popupButtonContainer addSubview:upIndicator];
        upIndicator.backgroundColor = [UIColor whiteColor];
        upIndicator.layer.cornerRadius = 5;
        [upIndicator makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(popupButtonContainer).offset(5);
            make.centerY.equalTo(popupButtonContainer);
            make.width.height.equalTo(@(ButtonWidth));
        }];
        
        UIImageView *coverImageView = [[UIImageView alloc] init];
        [popupButtonContainer addSubview:coverImageView];
        coverImageView.backgroundColor = [UIColor whiteColor];
        coverImageView.layer.cornerRadius = 5;
        [coverImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(popupButtonContainer).offset(5);
            make.bottom.right.equalTo(popupButtonContainer).offset(-5);
            make.width.equalTo(coverImageView.height);
        }];
        
        // player controler
        UIView *controlContainer = [[UIView alloc] init];
        [self addSubview:controlContainer];
        [controlContainer makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.width.equalTo(@((ButtonWidth + 5) * 4 + 5));
        }];
        
        UIButton *volumeControlButton = [[UIButton alloc] init];
        [controlContainer addSubview:volumeControlButton];
        volumeControlButton.backgroundColor = [UIColor whiteColor];
        volumeControlButton.layer.cornerRadius = 5;
        [volumeControlButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(controlContainer).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(ButtonWidth));
        }];
        
        UIButton *leftButton = [[UIButton alloc] init];
        [controlContainer addSubview:leftButton];
        leftButton.backgroundColor = [UIColor whiteColor];
        leftButton.layer.cornerRadius = 5;
        [leftButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(volumeControlButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(ButtonWidth));
        }];
        
        UIButton *playPauseButton = [[UIButton alloc] init];
        [controlContainer addSubview:playPauseButton];
        playPauseButton.backgroundColor = [UIColor whiteColor];
        playPauseButton.layer.cornerRadius = 5;
        [playPauseButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(ButtonWidth));
        }];
        
        UIButton *rightButton = [[UIButton alloc] init];
        [controlContainer addSubview:rightButton];
        rightButton.backgroundColor = [UIColor whiteColor];
        rightButton.layer.cornerRadius = 5;
        [rightButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(playPauseButton.right).offset(5);
            make.centerY.equalTo(controlContainer);
            make.width.height.equalTo(@(ButtonWidth));
        }];
        
        // caption label
        JPTrackLabel *trackLabel = [[JPTrackLabel alloc] init];
        [self addSubview:trackLabel];
        [trackLabel setWithTrack:@"Good Life" Singer:@"One Direction"];
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

@end

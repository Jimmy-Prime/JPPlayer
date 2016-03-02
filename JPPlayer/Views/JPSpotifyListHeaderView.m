//
//  JPSpotifyListHeaderView.m
//  JPPlayer
//
//  Created by Prime on 2/28/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyListHeaderView.h"

@interface JPSpotifyListHeaderView()

@property (strong, nonatomic) UILabel *indicator;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation JPSpotifyListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor JPColor];
        
        _indicator = [[UILabel alloc] init];
        _indicator.textColor = [UIColor whiteColor];
        _indicator.textAlignment = NSTextAlignmentCenter;
        _indicator.font = [UIFont systemFontOfSize:11];
        [self addSubview:_indicator];
        [_indicator makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-8.f);
            make.left.right.equalTo(self);
            make.height.equalTo(@(14.f));
        }];
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loginButton setImage: [[UIImage imageNamed: @"spotify_listen"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
        _loginButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _loginButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [_loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loginButton];
        [_loginButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(8.f);
            make.left.right.equalTo(self);
            make.bottom.equalTo(_indicator.top).offset(-8.f);
        }];
    }
    
    return self;
}

- (void)setState:(JPSpotifyHeaderState)state {
    _state = state;
    switch (state) {
        case JPSpotifyHeaderCreating:
            _loginButton.enabled = NO;
            _indicator.text = @"Creating session";
            break;
            
        case JPSpotifyHeaderRenewing:
            _loginButton.enabled = NO;
            _indicator.text = @"Renewing session";
            break;
            
        case JPSpotifyHeaderLogging:
            _loginButton.enabled = NO;
            _indicator.text = @"Logging in";
            break;
            
        case JPSpotifyHeaderRetrieving:
            _loginButton.enabled = NO;
            _indicator.text = @"Retrieving playlists";
            break;
            
        case JPSpotifyHeaderDone:
            _loginButton.enabled = YES;
            [_loginButton setImage: [[UIImage imageNamed: @"spotify_listen"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
            _indicator.text = @"Tap to refresh";
            break;
            
        default:
            _loginButton.enabled = YES;
            [_loginButton setImage: [[UIImage imageNamed: @"spotify_login"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
            _indicator.text = @"No session";
            break;
    }
}

- (void)login:(UIButton *)button {
    if (_state == JPSpotifyHeaderDone) {
        [_delegate refresh];
    }
    else {
        self.state = JPSpotifyHeaderCreating;
        [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].loginURL];
    }
}

@end

//
//  JPLaunchViewController.m
//  JPPlayer
//
//  Created by Prime on 3/15/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPLaunchViewController.h"
#import "JPSpotifySession.h"

@interface JPLaunchViewController ()

@property (strong, nonatomic) UIImageView *logoImageView;

@property (strong, nonatomic) UIImageView *connect;
@property (strong, nonatomic) UIImageView *outerL;
@property (strong, nonatomic) UIImageView *outerR;
@property (strong, nonatomic) UIImageView *innerL;
@property (strong, nonatomic) UIImageView *innerR;

@property (strong, nonatomic) UILabel *sessionState;

@end

@implementation JPLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    _connect = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo connect.png"]];
    [self.view addSubview:_connect];
    [_connect makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    }];

    _outerL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo outer L.png"]];
    [self.view addSubview:_outerL];
    [_outerL makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    }];

    _outerR = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo outer R.png"]];
    [self.view addSubview:_outerR];
    [_outerR makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    }];

    _innerL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo inner L.png"]];
    [self.view addSubview:_innerL];
    [_innerL makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    }];

    _innerR = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo inner R.png"]];
    [self.view addSubview:_innerR];
    [_innerR makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    }];

    _sessionState = [[UILabel alloc] init];
    _sessionState.textAlignment = NSTextAlignmentCenter;
    _sessionState.textColor = [UIColor JPColor];
    _sessionState.hidden = YES;
    [self.view addSubview:_sessionState];
    [_sessionState makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGFloat animationInterval = 1.f;
    CGFloat bottomInset = -100.f;
    CGFloat horizontalInset = -48.f;

    [UIView animateWithDuration:animationInterval animations:^{
        void (^moveUp)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view.centerY).offset(bottomInset);
            make.centerX.equalTo(self.view);
            make.size.equalTo(@(512));
        };

        _connect.alpha = 0;
        [_connect remakeConstraints:moveUp];
        [_outerL remakeConstraints:moveUp];
        [_outerR remakeConstraints:moveUp];
        [_innerL remakeConstraints:moveUp];
        [_innerR remakeConstraints:moveUp];

        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationInterval animations:^{
            void (^moveLeft)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.centerY).offset(bottomInset);
                make.left.equalTo(self.view).offset(horizontalInset);
                make.size.equalTo(@(512));
            };

            [_outerL remakeConstraints:moveLeft];
            [_innerL remakeConstraints:moveLeft];

            void (^moveRight)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.centerY).offset(bottomInset);
                make.right.equalTo(self.view).offset(-horizontalInset);
                make.size.equalTo(@(512));
            };

            [_outerR remakeConstraints:moveRight];
            [_innerR remakeConstraints:moveRight];

            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            _sessionState.hidden = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifySessionStateChanged) name:SpotifySessionStateChanged object:nil];
            [[JPSpotifySession defaultInstance] checkSession];
        }];
    }];
}

- (void)spotifySessionStateChanged {
    switch ([JPSpotifySession defaultInstance].state) {
        case JPSpotifySessionNone:
            _sessionState.text = @"No Session";
            break;

        case JPSpotifySessionExpire:
            _sessionState.text = @"Session Expired";
            break;

        case JPSpotifySessionInvalid:
            _sessionState.text = @"Invalid Session";
            break;

        case JPSpotifySessionValid:
            _sessionState.text = @"Valid Session";
            [self performSelector:@selector(showPlayer) withObject:nil afterDelay:AnimationInterval];
            break;

        default:
            break;
    }
}

- (void)showPlayer {
    [self performSegueWithIdentifier:@"ShowPlayer" sender:self];
}

@end

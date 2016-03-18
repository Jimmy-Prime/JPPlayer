//
//  JPLaunchViewController.m
//  JPPlayer
//
//  Created by Prime on 3/15/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPLaunchViewController.h"
#import "JPSpotifySession.h"
#import "JPSpotifyPlayer.h"

@interface JPLaunchViewController ()

@property (strong, nonatomic) UIImageView *logoImageView;

@property (strong, nonatomic) UIImageView *connect;
@property (strong, nonatomic) UIImageView *outerL;
@property (strong, nonatomic) UIImageView *outerR;
@property (strong, nonatomic) UIImageView *innerL;
@property (strong, nonatomic) UIImageView *innerR;

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIImageView *sessionImage;
@property (strong, nonatomic) UILabel *sessionLabel;
@property (strong, nonatomic) UIImageView *playerImage;
@property (strong, nonatomic) UILabel *playerLabel;

@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation JPLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    void (^placeAtCenter)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(@(512));
    };

    _connect = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"logo connect.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _connect.tintColor = [UIColor JPColor];
    [self.view addSubview:_connect];
    [_connect makeConstraints:placeAtCenter];

    _outerL = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"logo outer L.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _outerL.tintColor = [UIColor JPColor];
    [self.view addSubview:_outerL];
    [_outerL makeConstraints:placeAtCenter];

    _outerR = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"logo outer R.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _outerR.tintColor = [UIColor JPColor];
    [self.view addSubview:_outerR];
    [_outerR makeConstraints:placeAtCenter];

    _innerL = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"logo inner L.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _innerL.tintColor = [UIColor JPColor];
    [self.view addSubview:_innerL];
    [_innerL makeConstraints:placeAtCenter];

    _innerR = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"logo inner R.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    _innerR.tintColor = [UIColor JPColor];
    [self.view addSubview:_innerR];
    [_innerR makeConstraints:placeAtCenter];

    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor JPSelectedCellColor];
    _container.layer.cornerRadius = 20.f;
    _container.alpha = 0.f;
    [self.view addSubview:_container];
    [_container makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(200.f));
        make.height.equalTo(@(95.f));
    }];

    UIView *topContainer = [[UIView alloc] init];
    [_container addSubview:topContainer];
    UIView *bottomContainer = [[UIView alloc] init];
    [_container addSubview:bottomContainer];

    [topContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_container).offset(5.f);
        make.bottom.equalTo(bottomContainer.top).offset(-5.f);
        make.right.equalTo(_container).offset(-5.f);
        make.height.equalTo(bottomContainer);
    }];

    [bottomContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_container).offset(5.f);
        make.bottom.right.equalTo(_container).offset(-5.f);
    }];

    UIImage *moreImage = [[UIImage imageNamed:@"ic_more_horiz_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    _sessionImage = [[UIImageView alloc] initWithImage:moreImage];
    _sessionImage.tintColor = [UIColor JPColor];
    [topContainer addSubview:_sessionImage];
    [_sessionImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(topContainer);
        make.width.equalTo(_sessionImage.height);
    }];
    [UIView animateKeyframesWithDuration:AnimationInterval*4.f delay:0.f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:1.f / 3.f animations:^{
            _sessionImage.transform = CGAffineTransformMakeRotation(M_PI * 2.0f / 3.0f);
        }];
        [UIView addKeyframeWithRelativeStartTime:1.f / 3.f relativeDuration:1.f / 3.f animations:^{
            _sessionImage.transform = CGAffineTransformMakeRotation(M_PI * 4.0f / 3.0f);
        }];
        [UIView addKeyframeWithRelativeStartTime:2.f / 3.f relativeDuration:1.f / 3.f animations:^{
            _sessionImage.transform = CGAffineTransformIdentity;
        }];
    } completion:nil];

    _sessionLabel = [[UILabel alloc] init];
    _sessionLabel.textAlignment = NSTextAlignmentCenter;
    _sessionLabel.textColor = [UIColor JPColor];
    _sessionLabel.text = @"Checking Session";
    [topContainer addSubview:_sessionLabel];
    [_sessionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(topContainer);
        make.left.equalTo(_sessionImage.right).offset(5.f);
    }];

    _playerImage = [[UIImageView alloc] initWithImage:moreImage];
    _playerImage.tintColor = [UIColor JPColor];
    [bottomContainer addSubview:_playerImage];
    [_playerImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(bottomContainer);
        make.width.equalTo(_playerImage.height);
    }];

    _playerLabel = [[UILabel alloc] init];
    _playerLabel.textAlignment = NSTextAlignmentCenter;
    _playerLabel.textColor = [UIColor JPColor];
    _playerLabel.text = @"Waiting";
    [bottomContainer addSubview:_playerLabel];
    [_playerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(bottomContainer);
        make.left.equalTo(_playerImage.right).offset(5.f);
    }];

    _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_loginButton setImage: [[UIImage imageNamed: @"spotify_login"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
    _loginButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _loginButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.alpha = 0.f;
    [self.view addSubview:_loginButton];
    [_loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-8.f);
        make.centerX.equalTo(self.view);
        // 488 * 88
        make.width.equalTo(@(244.f));
        make.height.equalTo(@(44.f));
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGFloat bottomInset = -100.f;
    CGFloat horizontalInset = 80.f;

    [UIView animateWithDuration:AnimationInterval delay:AnimationInterval*3.f options:0 animations:^{
        void (^moveUp)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view).offset(bottomInset);
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
        [UIView animateWithDuration:AnimationInterval animations:^{
            void (^moveLeft)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(bottomInset);
                make.centerX.equalTo(self.view).offset(-horizontalInset);
                make.size.equalTo(@(512));
            };

            [_outerL remakeConstraints:moveLeft];
            [_innerL remakeConstraints:moveLeft];

            void (^moveRight)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(bottomInset);
                make.centerX.equalTo(self.view).offset(horizontalInset);
                make.size.equalTo(@(512));
            };

            [_outerR remakeConstraints:moveRight];
            [_innerR remakeConstraints:moveRight];

            [self.view layoutIfNeeded];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:AnimationInterval animations:^{
                _container.alpha = 1.f;

            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifySessionStateChanged) name:SpotifySessionStateChanged object:nil];
                [[JPSpotifySession defaultInstance] checkSession];
            }];
        }];
    }];
}

- (void)spotifySessionStateChanged {
    switch ([JPSpotifySession defaultInstance].state) {
        case JPSpotifySessionNone:
        case JPSpotifySessionInvalid: {
            _sessionLabel.text = @"Invalid Session";

            [_sessionImage.layer removeAllAnimations];

            UIImage *noneImage = [[UIImage imageNamed:@"ic_cancel_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _sessionImage.image = noneImage;

            [UIView animateWithDuration:AnimationInterval animations:^{
                _loginButton.alpha = 1.f;
            }];
            break;
        }

        case JPSpotifySessionExpire: {
            _sessionLabel.text = @"Renewing Session";

            UIImage *moreImage = [[UIImage imageNamed:@"ic_more_horiz_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _sessionImage.image = moreImage;
            [UIView animateKeyframesWithDuration:AnimationInterval*4.f delay:0.f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:1.f / 3.f animations:^{
                    _sessionImage.transform = CGAffineTransformMakeRotation(M_PI * 2.0f / 3.0f);
                }];
                [UIView addKeyframeWithRelativeStartTime:1.f / 3.f relativeDuration:1.f / 3.f animations:^{
                    _sessionImage.transform = CGAffineTransformMakeRotation(M_PI * 4.0f / 3.0f);
                }];
                [UIView addKeyframeWithRelativeStartTime:2.f / 3.f relativeDuration:1.f / 3.f animations:^{
                    _sessionImage.transform = CGAffineTransformIdentity;
                }];
            } completion:nil];
            break;
        }

        case JPSpotifySessionValid: {
            _sessionLabel.text = @"Valid Session";

            [_sessionImage.layer removeAllAnimations];

            UIImage *doneImage = [[UIImage imageNamed:@"ic_check_circle_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _sessionImage.image = doneImage;

            _playerLabel.text = @"Logging in";

            [UIView animateKeyframesWithDuration:AnimationInterval*4.f delay:0.f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear animations:^{
                [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:1.f / 3.f animations:^{
                    _playerImage.transform = CGAffineTransformMakeRotation(M_PI * 2.0f / 3.0f);
                }];
                [UIView addKeyframeWithRelativeStartTime:1.f / 3.f relativeDuration:1.f / 3.f animations:^{
                    _playerImage.transform = CGAffineTransformMakeRotation(M_PI * 4.0f / 3.0f);
                }];
                [UIView addKeyframeWithRelativeStartTime:2.f / 3.f relativeDuration:1.f / 3.f animations:^{
                    _playerImage.transform = CGAffineTransformIdentity;
                }];
            } completion:nil];

            [UIView animateWithDuration:AnimationInterval animations:^{
                _loginButton.alpha = 0.f;
            }];

            [[JPSpotifyPlayer player] loginWithSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                _playerLabel.text = @"Logged in";
                [_playerImage.layer removeAllAnimations];
                _playerImage.image = doneImage;

                [self performSelector:@selector(showPlayer) withObject:nil afterDelay:AnimationInterval];
            }];

            break;
        }

        default:
            break;
    }
}

- (void)showPlayer {
    CGFloat bottomInset = -100.f;

    [UIView animateWithDuration:AnimationInterval animations:^{
        _container.alpha = 0.f;

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:AnimationInterval animations:^{
            void (^moveToMid)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view).offset(bottomInset);
                make.centerX.equalTo(self.view);
                make.size.equalTo(@(512));
            };

            [_outerL remakeConstraints:moveToMid];
            [_outerR remakeConstraints:moveToMid];
            [_innerL remakeConstraints:moveToMid];
            [_innerR remakeConstraints:moveToMid];

            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:AnimationInterval animations:^{
                void (^moveToMid)(MASConstraintMaker *) = ^void(MASConstraintMaker *make) {
                    make.center.equalTo(self.view);
                    make.size.equalTo(@(512));
                };

                _connect.alpha = 1.f;
                [_connect remakeConstraints:moveToMid];
                [_outerL remakeConstraints:moveToMid];
                [_outerR remakeConstraints:moveToMid];
                [_innerL remakeConstraints:moveToMid];
                [_innerR remakeConstraints:moveToMid];
                
                [self.view layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                [self performSegueWithIdentifier:@"ShowPlayer" sender:self];
            }];
        }];
    }];
}

- (void)login {
    [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].loginURL];

    _sessionLabel.text = @"Creating Session";

    UIImage *moreImage = [[UIImage imageNamed:@"ic_more_horiz_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _sessionImage.image = moreImage;
}

@end

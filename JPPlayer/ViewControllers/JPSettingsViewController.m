//
//  JPSettingsViewController.m
//  JPPlayer
//
//  Created by Prime on 1/25/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSettingsViewController.h"

@interface JPSettingsViewController ()

@end

@implementation JPSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifySession:) name:@"SpotifySession" object:nil];
    
    UIButton *spotifyLoginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [spotifyLoginButton setImage: [[UIImage imageNamed: @"spotify_login"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
    spotifyLoginButton.contentMode = UIViewContentModeScaleToFill;
    spotifyLoginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    spotifyLoginButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [spotifyLoginButton addTarget:self action:@selector(spotifyLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:spotifyLoginButton];
    [spotifyLoginButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(20);
        make.width.equalTo(@(488));
        make.height.equalTo(@(88));
    }];
}

- (void)spotifyLogin:(UIButton *)button {
    [[SPTAuth defaultInstance] setClientID:SpotifyClientId];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:SpotifyRedirectURL]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope]];
    [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].loginURL];
}
/*
- (void)spotifySession:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    SPTSession *session = [userInfo objectForKey:@"SpotifySession"];
    
    [SPTUser requestCurrentUserWithAccessToken:session.accessToken callback:^(NSError *error, SPTUser *user) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        
        NSString *userDetailsString = [NSString stringWithFormat:@""
                                       "Display name: %@\n"
                                       "Canonical name: %@\n"
                                       "Territory: %@\n"
                                       "Email: %@\n"
                                       "Images: %@ images\n"
                                       , user.displayName, user.canonicalUserName, user.territory, user.emailAddress, @(user.images.count)];
        
        NSLog(@"user: %@", userDetailsString);
    }];
}
*/
@end
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
    
    self.view.backgroundColor = [UIColor JPColor];
    
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
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeSystem];
    testButton.backgroundColor = [UIColor greenColor];
    testButton.layer.cornerRadius = 5.f;
    [testButton addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
    [testButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(@(50));
    }];
}

- (void)spotifyLogin:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[SPTAuth defaultInstance].loginURL];
}

- (void)test:(UIButton *)button {
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        if (error != nil) {
            NSLog(@"openURL error: %@", error);
            return;
        }
        
        NSLog(@"Renewed session");
        
        [SPTAuth defaultInstance].session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionKey object:nil userInfo:@{SpotifySessionKey : session}];
    };
    
    NSLog(@"Test renew session");
    
    NSLog(@"hasTokenRefreshService: %d", [SPTAuth defaultInstance].hasTokenRefreshService);
    
    NSLog(@"encryptedRefreshToken: %@", [SPTAuth defaultInstance].session.encryptedRefreshToken);
    
    NSLog(@"expirationDate: %@", [SPTAuth defaultInstance].session.expirationDate);
    
    NSLog(@"canonicalUsername: %@", [SPTAuth defaultInstance].session.canonicalUsername);
    
    
    [[SPTAuth defaultInstance] renewSession:[SPTAuth defaultInstance].session callback:authCallback];
    
    
    /*
     SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
     if (error != nil) {
     NSLog(@"openURL error: %@", error);
     return;
     }
     
     NSLog(@"Renewed session");
     
     [SPTAuth defaultInstance].session = session;
     [JPSpotifyPlayer player];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotifySession" object:nil userInfo:@{@"SpotifySession": session}];
     };
     
     [[SPTAuth defaultInstance] renewSession:session callback:authCallback];
     */
}

@end

//
//  JPSpotifySession.m
//  JPPlayer
//
//  Created by Prime on 2/28/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifySession.h"

@implementation JPSpotifySession

static id defaultInstance;

+ (instancetype)defaultInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        _openURLBlock = ^(NSError *error, SPTSession *session) {
            if (error != nil) {
                NSLog(@"openURL error: %@", error);
                return;
            }
            
            [SPTAuth defaultInstance].session = session;
            [weakSelf checkSession];
        };
        
        _state = JPSpotifySessionNone;
    }
    
    return self;
}

- (SPTSession *)session {
    [self checkSession];
    return [SPTAuth defaultInstance].session;
}

- (void)setState:(JPSpotifySessionState)state {
    if (_state != state ||
        state == JPSpotifySessionNone ||
        state == JPSpotifySessionInvalid) {
        _state = state;
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionStateChanged object:nil];
    }
}

- (void)checkSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTSession *session = auth.session;
    if (!session) {
        self.state = JPSpotifySessionNone;
    }
    else if ([session isValid]) {
        self.state = JPSpotifySessionValid;
    }
    else if (auth.hasTokenRefreshService) {
        self.state = JPSpotifySessionExpire;
        
        [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
            if (error) {
                NSLog(@"Renew session error: %@", error);
                return;
            }
            
            auth.session = session;
            [self checkSession];
        }];
    }
    else {
        self.state = JPSpotifySessionInvalid;
    }
}

@end

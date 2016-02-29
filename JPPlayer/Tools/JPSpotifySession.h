//
//  JPSpotifySession.h
//  JPPlayer
//
//  Created by Prime on 2/28/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSpotifySession : NSObject

typedef enum {
    JPSpotifySessionNone,
    JPSpotifySessionValid,
    JPSpotifySessionExpire,
    JPSpotifySessionInvalid
} JPSpotifySessionState;

+ (instancetype)defaultInstance;
- (SPTSession *)session;
- (void)checkSession;

@property (strong, nonatomic) SPTAuthCallback openURLBlock;
@property (nonatomic) JPSpotifySessionState state;

#define SpotifySessionStateChanged @"SpotifySessionStateChanged"

@end

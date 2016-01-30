//
//  JPSpotifyPlayer.h
//  JPPlayer
//
//  Created by Prime on 1/30/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSpotifyPlayer : NSObject <SPTAudioStreamingPlaybackDelegate>

+ (instancetype)defaultInstance;
+ (SPTAudioStreamingController *)playerWithCliendId:(NSString *)clientId;

#define SpotifyDidChangePlaybackStatus @"SpotifyDidChangePlaybackStatus"
#define SpotifyDidChangeToTrack @"SpotifyDidChangeToTrack"

@end

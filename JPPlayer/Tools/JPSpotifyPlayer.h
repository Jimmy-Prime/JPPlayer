//
//  JPSpotifyPlayer.h
//  JPPlayer
//
//  Created by Prime on 1/30/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSpotifyPlayer : NSObject <SPTAudioStreamingPlaybackDelegate>

typedef enum {
    JPSpotifyPlaybackNone,
    JPSpotifyPlaybackCycle,
    JPSpotifyPlaybackOne,
    JPSpotifyPlaybackModeCount
} JPSpotifyPlayback;

+ (instancetype)defaultInstance;
+ (SPTAudioStreamingController *)player;
- (void)playURIs:(NSArray *)URIs fromIndex:(NSInteger)index;
- (void)playPrevious;
- (void)playNext;

@property (nonatomic) JPSpotifyPlayback playbackState;
@property (nonatomic) BOOL shuffle;
@property (strong, nonatomic) NSArray *activeURIs;
@property (nonatomic) NSUInteger index;

#define SpotifyShowNextTrackAnimation @"SpotifyShowNextTrackAnimation"
#define SpotifyDidChangePlaybackStatus @"SpotifyDidChangePlaybackStatus"
#define SpotifyDidChangeToTrack @"SpotifyDidChangeToTrack"
#define SpotifyDidChangePlaybackMode @"SpotifyDidChangePlaybackMode"

@end

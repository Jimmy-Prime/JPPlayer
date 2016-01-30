//
//  JPSpotifyPlayer.m
//  JPPlayer
//
//  Created by Prime on 1/30/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyPlayer.h"

@implementation JPSpotifyPlayer

+ (instancetype)defaultInstance {
    static dispatch_once_t once;
    static id defaultInstance;
    dispatch_once(&once, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

+ (SPTAudioStreamingController *)playerWithCliendId:(NSString *)clientId {
    static SPTAudioStreamingController *_player = nil;
    static NSString *_clientId = nil;
    
    BOOL needsReInit = NO;
    if (![_clientId isEqualToString:clientId]) {
        _clientId = clientId;
        needsReInit = YES;
    }
    
    if (!_player || needsReInit) {
        _player = [[SPTAudioStreamingController alloc] initWithClientId:_clientId];
        _player.playbackDelegate = [JPSpotifyPlayer defaultInstance];
        _player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    if (![_player loggedIn]) {
        NSLog(@"$$$ Not yet logged in");
        [_player loginWithSession:[[SPTAuth defaultInstance] session] callback:^(NSError *error) {
            if (error) {
                NSLog(@"Player login error: %@", error);
                return;
            }
            
            NSLog(@"$$$ Logged in");
        }];
    }
    
    return _player;
}

#pragma mark - SPTAudioStreamingPlaybackDelegate
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"%@", SpotifyDidChangeToTrack);
    if (trackMetadata) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangeToTrack object:nil userInfo:@{@"trackMetadata" : trackMetadata}];
    }
    else {
        NSLog(@"nil trackMetadata");
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"%@", SpotifyDidChangePlaybackStatus);
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangePlaybackStatus object:nil userInfo:@{@"isPlaying" : @(isPlaying)}];
}

@end

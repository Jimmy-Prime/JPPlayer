//
//  JPSpotifyPlayer.m
//  JPPlayer
//
//  Created by Prime on 1/30/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyPlayer.h"

@implementation JPSpotifyPlayer

static id defaultInstance;
static SPTAudioStreamingController *_player = nil;
static NSArray *totalURIs = nil;
static NSArray *localURIs = nil;

+ (instancetype)defaultInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

+ (SPTAudioStreamingController *)player {
    if (!_player) {
        _player = [[SPTAudioStreamingController alloc] initWithClientId:[[SPTAuth defaultInstance] clientID]];
        _player.playbackDelegate = [JPSpotifyPlayer defaultInstance];
        _player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    if (![_player loggedIn]) {
        NSLog(@"$$$ Not yet logged in");
        [_player loginWithSession:[[SPTAuth defaultInstance] session] callback:^(NSError *error) {
            if (error) {
                NSLog(@"$$$ Player login error: %@", error);
                return;
            }
            
            NSLog(@"$$$ Logged in");
        }];
    }
    
    return _player;
}

+ (void)playURIs:(NSArray *)URIs fromIndex:(NSInteger)index {
//  This is part is hanging due to SPTAudioStreamingController can only hold 100 URIs
//  And issue https://github.com/spotify/ios-sdk/issues/367
//    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:URIs];
//    [temp addObjectsFromArray:URIs];
//    [temp addObjectsFromArray:URIs];
//    totalURIs = temp;
    NSInteger localIndex = index;
    if (index >= 100) {
        localURIs = [URIs subarrayWithRange:NSMakeRange(index - 50, [URIs count] - index + 50)];
        localIndex = 50;
    }
    else {
        localURIs = URIs;
    }
    
    [[self player] playURIs:localURIs fromIndex:(int)localIndex callback:nil];
}

#pragma mark - SPTAudioStreamingPlaybackDelegate
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"%@", SpotifyDidChangeToTrack);
    if (trackMetadata) {
        NSString *trackURI = [trackMetadata objectForKey:@"SPTAudioStreamingMetadataTrackURI"];
        
        NSURLRequest *trackRequest = [SPTTrack createRequestForTrack:[NSURL URLWithString:trackURI]
                                                     withAccessToken:[[[SPTAuth defaultInstance] session] accessToken]
                                                              market:nil
                                                               error:nil];
        
        [[SPTRequest sharedHandler] performRequest:trackRequest callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            
            SPTTrack *track = [SPTTrack trackFromData:data withResponse:response error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangeToTrack object:nil userInfo:@{@"track" : track}];
        }];
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

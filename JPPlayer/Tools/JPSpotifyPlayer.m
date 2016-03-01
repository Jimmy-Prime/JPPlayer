//
//  JPSpotifyPlayer.m
//  JPPlayer
//
//  Created by Prime on 1/30/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyPlayer.h"
#import "JPSpotifySession.h"
#import <MediaPlayer/MediaPlayer.h>

@interface JPSpotifyPlayer()

@property (strong, nonatomic) NSArray *URIs;
@property (strong, nonatomic) NSArray *shuffleURIs;

@end

@implementation JPSpotifyPlayer

static id defaultInstance;
static SPTAudioStreamingController *_player = nil;

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
        MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        [commandCenter.playCommand addTarget:self action:@selector(playPause)];
        [commandCenter.pauseCommand addTarget:self action:@selector(playPause)];
        [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playPause)];
        [commandCenter.previousTrackCommand addTarget:self action:@selector(playPrevious)];
        [commandCenter.nextTrackCommand addTarget:self action:@selector(playNext)];
    }
    
    return self;
}

- (void)setPlaybackState:(JPSpotifyPlayback)playbackState {
    _playbackState = playbackState;
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangePlaybackMode object:nil];
}

- (void)setShuffle:(BOOL)shuffle {
    _shuffle = shuffle;
    
    if (shuffle) {
        _shuffleURIs = [self shuffleArray];
        _activeURIs = _shuffleURIs;
    }
    else {
        _activeURIs = _URIs;
        
        for (NSUInteger i=0; i<_URIs.count; ++i) {
            if ([_URIs[i] isEqual:_shuffleURIs[_index]]) {
                _index = i;
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangePlaybackMode object:nil];
}

- (NSArray *)shuffleArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_URIs];

    for (NSInteger i = array.count-1; i>0; i--) {
        if (i == _index) {
            continue;
        }
        
        NSUInteger swapIndex = arc4random_uniform((u_int32_t)i+1);
        while (swapIndex == _index) {
            swapIndex = arc4random_uniform((u_int32_t)i+1);
        }
        
        [array exchangeObjectAtIndex:i withObjectAtIndex:swapIndex];
    }
    
    return array;
}

+ (SPTAudioStreamingController *)player {
    if (!_player) {
        _player = [[SPTAudioStreamingController alloc] initWithClientId:[[SPTAuth defaultInstance] clientID]];
        _player.playbackDelegate = [JPSpotifyPlayer defaultInstance];
        _player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    return _player;
}

- (void)playURIs:(NSArray *)URIs fromIndex:(NSInteger)index {
//  This is part is a work around due to SPTAudioStreamingController can only hold 100 URIs
//  And issue https://github.com/spotify/ios-sdk/issues/367
// Trick is place only one URI in SPTAudioStreamingController
    
    _index = index;
    _URIs = URIs;
    _shuffleURIs = [self shuffleArray];
    
    if (_shuffle) {
        _activeURIs = _shuffleURIs;
    }
    else {
        _activeURIs = _URIs;
    }
    
    [[JPSpotifyPlayer player] playURIs:@[_activeURIs[index]] fromIndex:0 callback:nil];
}

- (void)playPause {
    SPTAudioStreamingController *player = [JPSpotifyPlayer player];
    [player setIsPlaying:!player.isPlaying callback:nil];
}

- (void)playPrevious {
    if (!_activeURIs.count) {
        return;
    }
    
    if (_index == 0) {
        if (_playbackState == JPSpotifyPlaybackNone) {
            [[JPSpotifyPlayer player] stop:nil];
        }
        else {
            _index = _activeURIs.count - 1;
            [[JPSpotifyPlayer player] playURIs:@[_activeURIs[_index]] fromIndex:0 callback:nil];
        }
    }
    else {
        _index--;
        [[JPSpotifyPlayer player] playURIs:@[_activeURIs[_index]] fromIndex:0 callback:nil];
    }
}

- (void)playNext {
    if (!_activeURIs.count) {
        return;
    }
    
    _index++;
    if (_index == _activeURIs.count) {
        _index = 0;
        if (_playbackState == JPSpotifyPlaybackNone) {
            _index = _activeURIs.count - 1;
            [[JPSpotifyPlayer player] stop:nil];
        }
        else {
            [[JPSpotifyPlayer player] playURIs:@[_activeURIs[_index]] fromIndex:0 callback:nil];
        }
    }
    else {
        [[JPSpotifyPlayer player] playURIs:@[_activeURIs[_index]] fromIndex:0 callback:nil];
    }
}

#pragma mark - SPTAudioStreamingPlaybackDelegate
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(SpotifyDidChangeToTrack);
    if (trackMetadata) {
        NSString *trackURI = [trackMetadata objectForKey:@"SPTAudioStreamingMetadataTrackURI"];
        
        [SPTTrack trackWithURI:[NSURL URLWithString:trackURI] session:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTTrack *track) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            
            UIImage *urlImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:track.album.largestCover.imageURL]];
            MPMediaItemArtwork *cover = [[MPMediaItemArtwork alloc] initWithImage:urlImage];
            
            NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
            nowPlayingInfo[MPMediaItemPropertyTitle] = track.name;
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.album.name;
            nowPlayingInfo[MPMediaItemPropertyArtist] = ((SPTPartialArtist *)track.artists.firstObject).name;
            nowPlayingInfo[MPMediaItemPropertyArtwork] = cover;
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(track.duration);
            nowPlayingInfo[MPMediaItemPropertyAlbumTrackNumber] = @(track.trackNumber);
            
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangeToTrack object:nil userInfo:@{@"track" : track}];
        }];
    }
    else {
        NSLog(@"nil trackMetadata"); // skip to next track
        
        if (_playbackState == JPSpotifyPlaybackOne) {
            [[JPSpotifyPlayer player] playURIs:@[_activeURIs[_index]] fromIndex:0 callback:nil];
        }
        else {
            [self playNext];
            [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyShowNextTrackAnimation object:nil];
        }
    }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(SpotifyDidChangePlaybackStatus);
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidChangePlaybackStatus object:nil userInfo:@{@"isPlaying" : @(isPlaying)}];
}

@end

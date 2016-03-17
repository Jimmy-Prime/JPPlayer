//
//  JPAlbumTableViewController.m
//  JPPlayer
//
//  Created by Prime on 3/7/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPAlbumTableViewController.h"
#import "JPTrackCell.h"
#import "JPSpotifyPlayer.h"

@interface JPAlbumTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation JPAlbumTableViewController
@synthesize blurBackgroundImageView = _blurBackgroundImageView;
@synthesize profileImageView = _profileImageView;
@synthesize titleLabel = _titleLabel;
@synthesize list = _list;

@synthesize information = _information;
@synthesize tracks = _tracks;

- (void)viewDidLoad {
    [super viewDidLoad];

    _blurBackgroundImageView = super.blurBackgroundImageView;
    _profileImageView = super.profileImageView;
    _titleLabel = super.titleLabel;
    _list = super.list;

    _information = super.information;
    _tracks = super.tracks;

    _list.dataSource = self;
    _list.delegate = self;
}

- (void)setInformation:(id)information {
    _information = information;
    SPTPartialAlbum *partialAlbum = (SPTPartialAlbum *)_information;
    [SPTAlbum albumWithURI:partialAlbum.uri accessToken:nil market:nil callback:^(NSError *error, SPTAlbum *album) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_blurBackgroundImageView setImageWithURL:album.largestCover.imageURL];
        [_profileImageView setImageWithURL:album.largestCover.imageURL];
        _titleLabel.text = album.name;

        [_tracks addObjectsFromArray:album.tracksForPlayback];
        [_list reloadData];
        [self checkNewPage:album.firstTrackPage];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { // list section
        JPTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:JPTrackCellIdentifier];
        if (cell == nil) {
            cell = [[JPTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPTrackCellIdentifier];
        }

        SPTPartialTrack *track = _tracks[indexPath.row];
        if (![track isKindOfClass:[SPTTrack class]]) {
            [SPTTrack trackWithURI:track.uri session:nil callback:^(NSError *error, SPTTrack *track) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                _tracks[indexPath.row] = track;
            }];
        }

        cell.track = _tracks[indexPath.row];

        NSString *artists = ((SPTPartialArtist *)(track.artists.firstObject)).name;
        for (NSInteger i=1; i<track.artists.count; ++i) {
            SPTPartialArtist *partialArtist = track.artists[i];
            artists = [artists stringByAppendingString:[NSString stringWithFormat:@", %@", partialArtist.name]];
        }

        cell.auxilaryLabel.text = artists;

        return cell;
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _tracks.count;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return JPTrackCellHeight;
    }

    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSMutableArray *URIs = [[NSMutableArray alloc] init];

        for (SPTPartialTrack *track in _tracks) {
            [URIs addObject:[track uri]];
        }

        [[JPSpotifyPlayer defaultInstance] playURIs:URIs fromIndex:indexPath.row];
    }
}

@end

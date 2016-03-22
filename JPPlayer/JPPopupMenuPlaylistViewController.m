//
//  JPPopupMenuTableViewController.m
//  JPPlayer
//
//  Created by Prime on 3/21/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPPopupMenuPlaylistViewController.h"
#import "JPPopupMenuViewController.h"
#import "JPPlaylistCell.h"
#import "JPSpotifySession.h"

@interface JPPopupMenuPlaylistViewController ()

@property (strong, nonatomic) NSMutableArray *playlists;

@end

@implementation JPPopupMenuPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor JPBackgroundColor];
    self.tableView.separatorColor = [UIColor JPSeparatorColor];

    SPTSession *session = [JPSpotifySession defaultInstance].session;
    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, SPTPlaylistList *lists) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        _playlists = [NSMutableArray arrayWithArray:lists.items];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _playlists ? _playlists.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JPPlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:JPPlaylistCellIdentifier];
    if (!cell) {
        cell = [[JPPlaylistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPPlaylistCellIdentifier];
    }

    SPTPartialPlaylist *partialPlayList = _playlists[indexPath.row];
    if ([partialPlayList isKindOfClass:[SPTPlaylistSnapshot class]]) {
        [self setCell:cell with:partialPlayList];
    }
    else {
        [SPTPlaylistSnapshot playlistWithURI:partialPlayList.uri session:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
            _playlists[indexPath.row] = playlist;
            [self setCell:cell with:playlist];
        }];
    }

    return cell;
}

- (void)setCell:(JPPlaylistCell *)cell with:(SPTPartialPlaylist *)_playlist {
    SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot *)_playlist;
    UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
    [cell.profileImageView setImageWithURL:playlist.smallestImage.imageURL placeholderImage:placeHolder];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", playlist.name];
    cell.auxilaryLabel.text = [@(playlist.trackCount) stringValue];
    cell.rightArrowImageView.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return JPPlaylistCellHeight;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPTPlaylistSnapshot *playlist = _playlists[indexPath.row];

    [playlist addTracksToPlaylist:@[_track] withSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }

        [[JPPopupMenuViewController defaultInstance] dismissMenu];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }];
}

@end

//
//  JPArtistTableViewController.m
//  JPPlayer
//
//  Created by Prime on 3/14/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPArtistTableViewController.h"
#import "JPSpotifyListTableViewCell.h"
#import "JPSpotifySession.h"

@interface JPArtistTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *topTracks; // SPTTrack
@property (strong, nonatomic) NSArray *relatedArtists; // SPTArtist
@property (strong, nonatomic) NSMutableArray *albums; // SPTPartialAlbum
@property (strong, nonatomic) NSMutableArray *singles; // SPTPartialAlbum

@end

@implementation JPArtistTableViewController
@synthesize blurBackgroundImageView = _blurBackgroundImageView;
@synthesize profileImageView = _profileImageView;
@synthesize titleLabel = _titleLabel;
@synthesize list = _list;

@synthesize information = _information;

- (void)viewDidLoad {
    [super viewDidLoad];

    _blurBackgroundImageView = super.blurBackgroundImageView;
    _profileImageView = super.profileImageView;
    _titleLabel = super.titleLabel;
    _list = super.list;

    _information = super.information;

    _list.dataSource = self;
    _list.delegate = self;

    _albums = [[NSMutableArray alloc] init];
    _singles = [[NSMutableArray alloc] init];
}

- (void)setInformation:(id)information {
    _information = information;
    SPTPartialArtist *partialArtist = (SPTPartialArtist *)_information;
    [SPTArtist artistWithURI:partialArtist.uri accessToken:nil callback:^(NSError *error, SPTArtist *artist) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_blurBackgroundImageView setImageWithURL:artist.largestImage.imageURL];
        [_profileImageView setImageWithURL:artist.largestImage.imageURL];
        _titleLabel.text = artist.name;

        SPTSession *session = [JPSpotifySession defaultInstance].session;

        [artist requestTopTracksForTerritory:@"TW" withSession:session callback:^(NSError *error, NSArray *topTracks) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            _topTracks = topTracks;
            [_list reloadData];
        }];

        [artist requestRelatedArtistsWithSession:session callback:^(NSError *error, NSArray *relatedArtists) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            _relatedArtists = relatedArtists;
            [_list reloadData];
        }];

        [artist requestAlbumsOfType:SPTAlbumTypeAlbum withSession:session availableInTerritory:nil callback:^(NSError *error, SPTListPage *page) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            [_albums addObjectsFromArray:page.items];
            [_list reloadData];
            [self checkNewPage:page withContainer:_albums];
        }];

        [artist requestAlbumsOfType:SPTAlbumTypeSingle withSession:session availableInTerritory:nil callback:^(NSError *error, SPTListPage *page) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            [_singles addObjectsFromArray:page.items];
            [_list reloadData];
            [self checkNewPage:page withContainer:_singles];
        }];
    }];
}

- (void)checkNewPage:(SPTListPage *)page withContainer:(NSMutableArray *)container {
    if (page.hasNextPage) {
        [page requestNextPageWithSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTListPage *nextPage) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            [container addObjectsFromArray:nextPage.items];
            [_list reloadData];

            if (nextPage.hasNextPage) {
                [self checkNewPage:nextPage withContainer:container];
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JPSpotifyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JPSpotifyListTableViewCellIdentifier];
    if (!cell) {
        cell = [[JPSpotifyListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPSpotifyListTableViewCellIdentifier];
    }

//    UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
    SPTPartialAlbum *album;
    switch (indexPath.section) {
        case 1: {
            SPTTrack *track = _topTracks[indexPath.row];
//            [cell.imageView setImageWithURL:track.album.smallestCover.imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = track.name;
            cell.auxilaryLabel.text = track.album.name;
            break;
        }

        case 2: {
            SPTArtist *artist = _relatedArtists[indexPath.row];
//            [cell.imageView setImageWithURL:artist.smallestImage.imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = artist.name;
            cell.auxilaryLabel.text = artist.genres.firstObject;
            break;
        }

        case 3:
            album = _albums[indexPath.row];

        case 4:
            album = _singles[indexPath.row];

//            [cell.imageView setImageWithURL:album.smallestCover.imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = album.name;
            cell.auxilaryLabel.text = album.identifier;
            break;
            
        default:
            break;
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return _topTracks.count;

        case 2:
            return _relatedArtists.count;

        case 3:
            return _albums.count;

        case 4:
            return _singles.count;

        default:
            break;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return JPSpotifyListTableCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return ContainerWidth;
    }

    return 100.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section) {
        return nil;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, ContainerWidth, 100.f}];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor JPSelectedCellColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:36];
    switch (section) {
        case 1:
            label.text = @"Top Tracks";
            break;

        case 2:
            label.text = @"Related Artists";
            break;

        case 3:
            label.text = @"Albums";
            break;

        case 4:
            label.text = @"Singles";
            break;
            
        default:
            break;
    }

    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end

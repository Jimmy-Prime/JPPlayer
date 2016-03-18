//
//  JPArtistTableViewController.m
//  JPPlayer
//
//  Created by Prime on 3/14/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPArtistCollectionViewController.h"
#import "JPAlbumTableViewController.h"
#import "JPCollectionViewCell.h"
#import "JPSpotifySession.h"
#import "JPSpotifyPlayer.h"

@interface JPArtistCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *topTracks; // SPTTrack
@property (strong, nonatomic) NSArray *relatedArtists; // SPTArtist
@property (strong, nonatomic) NSMutableArray *albums; // SPTPartialAlbum
@property (strong, nonatomic) NSMutableArray *singles; // SPTPartialAlbum

@end

@implementation JPArtistCollectionViewController
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

    [_list registerClass:[JPCollectionViewCell class] forCellWithReuseIdentifier:JPCollectionViewCellIdentifier];
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPCollectionViewCellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[JPCollectionViewCell alloc] init];
    }

    UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
    SPTPartialAlbum *album;
    CGFloat width = (ContainerWidth - 60.f) / 2.f;
    CGSize imageSize = (CGSize){width, width};
    switch (indexPath.section) {
        case 1: {
            SPTTrack *track = _topTracks[indexPath.row];
            [cell.profileImageView setImageWithURL:[track.album imageClosestToSize:imageSize].imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = track.name;
            break;
        }

        case 2: {
            SPTArtist *artist = _relatedArtists[indexPath.row];
            [cell.profileImageView setImageWithURL:[artist imageClosestToSize:imageSize].imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = artist.name;
            break;
        }

        case 3:
            album = _albums[indexPath.row];

        case 4:
            album = _singles[indexPath.row];

            [cell.profileImageView setImageWithURL:[album imageClosestToSize:imageSize].imageURL placeholderImage:placeHolder];
            cell.titleLabel.text = album.name;
            break;
            
        default:
            break;
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        #warning custom header not working, this is a work around
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JPContainerCollectionViewHeader" forIndexPath:indexPath];

        UILabel *label = header.subviews.firstObject;
        if (!label) {
            label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, ContainerWidth, FakeHeaderHeight}];
            label.backgroundColor = [UIColor JPSelectedCellColor];
            label.font = [UIFont systemFontOfSize:28];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"Not Available";
            [header addSubview:label];
        }

        label.hidden = NO;
        switch (indexPath.section) {
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
                label.hidden = YES;
                break;
        }

        return header;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: {
            SPTTrack *track = _topTracks[indexPath.row];
            [[JPSpotifyPlayer defaultInstance] playURIs:@[track.uri] fromIndex:0];
            break;
        }

        case 2: {
            JPArtistCollectionViewController *newArtistVC = [[JPArtistCollectionViewController alloc] init];
            newArtistVC.information = _relatedArtists[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newArtistVC}];
            break;
        }

        case 3: {
            JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
            newAlbumVC.information = _albums[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newAlbumVC}];
            break;
        }

        case 4: {
            JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
            newAlbumVC.information = _singles[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newAlbumVC}];
            break;
        }

        default:
            break;
    }
}

@end

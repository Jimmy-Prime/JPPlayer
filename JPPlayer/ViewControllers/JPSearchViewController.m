//
//  JPSearchViewController.m
//  JPPlayer
//
//  Created by Prime on 3/18/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPSearchViewController.h"
#import "JPArtistCollectionViewController.h"
#import "JPAlbumTableViewController.h"
#import "JPListTableViewController.h"
#import "JPCollectionViewCell.h"
#import "JPSpotifySession.h"
#import "JPSpotifyPlayer.h"

@interface JPSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic) CGSize cellSize;

@property (strong, nonatomic) UICollectionView *tracks;
@property (strong, nonatomic) NSMutableArray *tracksList;

@property (strong, nonatomic) UICollectionView *artists;
@property (strong, nonatomic) NSMutableArray *artistsList;

@property (strong, nonatomic) UICollectionView *albums;
@property (strong, nonatomic) NSMutableArray *albumsList;

@property (strong, nonatomic) UICollectionView *playlists;
@property (strong, nonatomic) NSMutableArray *playlistsList;

@end

@implementation JPSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"Search";
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.tintColor = [UIColor JPColor];
    searchBar.delegate = self;
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor JPColor]];
    [self.view addSubview:searchBar];
    [searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight));
    }];

    _scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    [_scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar.bottom);
        make.bottom.left.right.equalTo(self.view);
    }];

    _cellSize = (CGSize){210.f, 250.f};

    _tracksList = [[NSMutableArray alloc] init];
    UIView *tracksSection = [self sectionWithTitle:@"Tracks" andCollectionView:&_tracks];
    [tracksSection makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.width.equalTo(_scrollView);
        make.height.equalTo(@(PlayerViewHeight + _cellSize.height));
    }];

    _artistsList = [[NSMutableArray alloc] init];
    UIView *artistSection = [self sectionWithTitle:@"Artists" andCollectionView:&_artists];
    [artistSection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tracksSection.bottom).offset(15.f);
        make.centerX.width.equalTo(_scrollView);
        make.height.equalTo(@(PlayerViewHeight + _cellSize.height));
    }];

    _albumsList = [[NSMutableArray alloc] init];
    UIView *albumSection = [self sectionWithTitle:@"Albums" andCollectionView:&_albums];
    [albumSection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(artistSection.bottom).offset(15.f);
        make.centerX.width.equalTo(_scrollView);
        make.height.equalTo(@(PlayerViewHeight + _cellSize.height));
    }];

    _playlistsList = [[NSMutableArray alloc] init];
    UIView *playlistSection = [self sectionWithTitle:@"Artists" andCollectionView:&_playlists];
    [playlistSection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(albumSection.bottom).offset(15.f);
        make.bottom.equalTo(_scrollView);
        make.centerX.width.equalTo(_scrollView);
        make.height.equalTo(@(PlayerViewHeight + _cellSize.height));
    }];
}

- (UIView *)sectionWithTitle:(NSString *)title andCollectionView:(UICollectionView * __strong *)collectionView {
    UIView *container = [[UIView alloc] init];
    [_scrollView addSubview:container];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor JPSeparatorColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [container addSubview:titleLabel];

    UICollectionViewFlowLayout *featureFlow = [[UICollectionViewFlowLayout alloc] init];
    featureFlow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    featureFlow.minimumLineSpacing = 15.f;
    featureFlow.minimumInteritemSpacing = 15.f;
    featureFlow.itemSize = _cellSize;

    *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:featureFlow];
    (*collectionView).backgroundColor = [UIColor JPBackgroundColor];
    (*collectionView).showsHorizontalScrollIndicator = NO;
    [*collectionView registerClass:[JPCollectionViewCell class] forCellWithReuseIdentifier:JPCollectionViewCellIdentifier];
    (*collectionView).dataSource = self;
    (*collectionView).delegate = self;
    [container addSubview:*collectionView];

    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(container);
        make.bottom.equalTo((*collectionView).top);
    }];

    [*collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(container);
        make.left.equalTo(container).offset(15.f);
        make.right.equalTo(container).offset(-15.f);
        make.height.equalTo(@(_cellSize.height));
    }];

    return container;
}

#pragma make - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _tracks && _tracksList) {
        return _tracksList.count;
    }
    if (collectionView == _artists && _artistsList) {
        return _artistsList.count;
    }
    if (collectionView == _albums && _albumsList) {
        return  _albumsList.count;
    }
    if (collectionView == _playlists && _playlistsList) {
        return _playlistsList.count;
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPCollectionViewCellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[JPCollectionViewCell alloc] init];
    }

    if (collectionView == _tracks) {
        SPTPartialTrack *partialTrack = _tracksList[indexPath.row];
        if ([partialTrack isKindOfClass:[SPTTrack class]]) {
            [self setCell:cell withObject:partialTrack];
        }
        else {
            [SPTTrack trackWithURI:partialTrack.uri session:nil callback:^(NSError *error, SPTTrack *track) {
                _tracksList[indexPath.row] = track;
                [self setCell:cell withObject:track];
            }];
        }
    }
    else if (collectionView == _artists) {
        SPTPartialArtist *partialArtist = _artistsList[indexPath.row];
        if ([partialArtist isKindOfClass:[SPTArtist class]]) {
            [self setCell:cell withObject:partialArtist];
        }
        else {
            [SPTArtist artistWithURI:partialArtist.uri session:nil callback:^(NSError *error, SPTArtist *artist) {
                _artistsList[indexPath.row] = artist;
                [self setCell:cell withObject:artist];
            }];
        }
    }
    else if (collectionView == _albums) {
        SPTPartialAlbum *partialAlbum = _albumsList[indexPath.row];
        if ([partialAlbum isKindOfClass:[SPTAlbum class]]) {
            [self setCell:cell withObject:partialAlbum];
        }
        else {
            [SPTAlbum albumWithURI:partialAlbum.uri accessToken:nil market:nil callback:^(NSError *error, SPTAlbum *album) {
                _albumsList[indexPath.row] = album;
                [self setCell:cell withObject:album];
            }];
        }
    }
    else if (collectionView == _playlists) {
        SPTPartialPlaylist *partialPlaylist = _playlistsList[indexPath.row];
        if ([partialPlaylist isKindOfClass:[SPTPlaylistSnapshot class]]) {
            [self setCell:cell withObject:partialPlaylist];
        }
        else {
            [SPTPlaylistSnapshot playlistWithURI:partialPlaylist.uri session:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
                _playlistsList[indexPath.row] = playlist;
                [self setCell:cell withObject:playlist];
            }];
        }
    }

    return cell;
}

#pragma make - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _tracks) {
        SPTTrack *track = _tracksList[indexPath.row];
        [[JPSpotifyPlayer defaultInstance] playURIs:@[track.uri] fromIndex:0];
    }
    else if (collectionView == _artists) {
        JPArtistCollectionViewController *newArtistVC = [[JPArtistCollectionViewController alloc] init];
        newArtistVC.information = _artistsList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newArtistVC}];
    }
    else if (collectionView == _albums) {
        JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
        newAlbumVC.information = _albumsList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newAlbumVC}];
    }
    else if (collectionView == _playlists) {
        JPListTableViewController *newListVC = [[JPListTableViewController alloc] init];
        newListVC.information = _playlistsList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newListVC}];
    }
}

- (void)setCell:(JPCollectionViewCell *)cell withObject:(id)object {
    UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
    if ([object isKindOfClass:[SPTTrack class]]) {
        SPTTrack *track = (SPTTrack *)object;
        [cell.profileImageView setImageWithURL:[track.album imageClosestToSize:_cellSize].imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = track.name;
    }
    else if ([object isKindOfClass:[SPTArtist class]]) {
        SPTArtist *artist = (SPTArtist *)object;
        [cell.profileImageView setImageWithURL:[artist imageClosestToSize:_cellSize].imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = artist.name;
    }
    else if ([object isKindOfClass:[SPTAlbum class]]) {
        SPTAlbum *album = (SPTAlbum *)object;
        [cell.profileImageView setImageWithURL:[album imageClosestToSize:_cellSize].imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = album.name;
    }
    else if ([object isKindOfClass:[SPTPlaylistSnapshot class]]) {
        SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot *)object;
        [cell.profileImageView setImageWithURL:[playlist imageClosestToSize:_cellSize].imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = playlist.name;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypeTrack accessToken:nil callback:^(NSError *error, SPTListPage *page) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_tracksList removeAllObjects];
        [_tracksList addObjectsFromArray:page.items];
        [_tracks reloadData];
    }];

    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypeArtist accessToken:nil callback:^(NSError *error, SPTListPage *page) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_artistsList removeAllObjects];
        [_artistsList addObjectsFromArray:page.items];
        [_artists reloadData];
    }];

    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypeAlbum accessToken:nil callback:^(NSError *error, SPTListPage *page) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_albumsList removeAllObjects];
        [_albumsList addObjectsFromArray:page.items];
        [_albums reloadData];
    }];

    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypePlaylist accessToken:nil callback:^(NSError *error, SPTListPage *page) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }

        [_playlistsList removeAllObjects];
        [_playlistsList addObjectsFromArray:page.items];
        [_playlists reloadData];
    }];
}

@end

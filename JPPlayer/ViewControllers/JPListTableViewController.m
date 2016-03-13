//
//  JPListTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPListTableViewController.h"
#import "JPListControlView.h"
#import "JPSpotifyListTableViewCell.h"
#import "JPSpotifyPlayer.h"

@interface JPListTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, JPListControlDelegate>

@property (strong, nonatomic) JPListControlView *controlView;

@property (strong, nonatomic) NSMutableArray<SPTPlaylistTrack *> *filteredTracks;
@property (nonatomic) BOOL isSearching;

@end

@implementation JPListTableViewController
@synthesize blurBackgroundImageView = _blurBackgroundImageView;
@synthesize profileImageView = _profileImageView;
@synthesize titleLabel = _titleLabel;
@synthesize list = _list;
@synthesize fakeHeaderView = _fakeHeaderView;

@synthesize information = _information;
@synthesize tracks = _tracks;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    _blurBackgroundImageView = super.blurBackgroundImageView;
    _profileImageView = super.profileImageView;
    _titleLabel = super.titleLabel;
    _list = super.list;
    _fakeHeaderView = super.fakeHeaderView;

    _information = super.information;
    _tracks = super.tracks;
    
    _list.dataSource = self;
    _list.delegate = self;

    _controlView = [[JPListControlView alloc] init];
    _controlView.delegate = self;
    _controlView.searchBar.delegate = self;
    [_fakeHeaderView addSubview:_controlView];
    [_controlView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_fakeHeaderView);
    }];

    
    _filteredTracks = [[NSMutableArray alloc] init];
    _isSearching = NO;
}

- (void)setInformation:(id)information {
    _information = information;
    SPTPartialPlaylist *partialPlayList = (SPTPartialPlaylist *)_information;
    [SPTPlaylistSnapshot playlistWithURI:partialPlayList.uri session:[[SPTAuth defaultInstance] session] callback:^(NSError *error, SPTPlaylistSnapshot *playList) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        
        [_blurBackgroundImageView setImageWithURL:[[playList largestImage] imageURL]];
        [_profileImageView setImageWithURL:[[playList largestImage] imageURL]];
        _titleLabel.text = playList.name;
        
        [_tracks addObjectsFromArray:playList.tracksForPlayback];
        [_list reloadData];
        [self checkNewPage:playList.firstTrackPage];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { // list section
        JPSpotifyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JPSpotifyListTableViewCellIdentifier];
        if (cell == nil) {
            cell = [[JPSpotifyListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPSpotifyListTableViewCellIdentifier];
        }

        cell.track = _isSearching ? [_filteredTracks objectAtIndex:indexPath.row] : [_tracks objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    if (section == 1) {
        return _isSearching ? _filteredTracks.count : _tracks.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return JPSpotifyListTableCellHeight;
    }
    
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSMutableArray *URIs = [[NSMutableArray alloc] init];
        if (_isSearching) {
            for (SPTPlaylistTrack *track in _filteredTracks) {
                [URIs addObject:[track uri]];
            }
        }
        else {
            for (SPTPlaylistTrack *track in _tracks) {
                [URIs addObject:[track uri]];
            }
        }
        
        [[JPSpotifyPlayer defaultInstance] playURIs:URIs fromIndex:indexPath.row];
    }
}

#pragma mark - JPListControlDelegate
- (void)sendControlEvent:(JPControlEvent)event ascending:(BOOL)ascending {
    NSMutableArray<SPTPlaylistTrack *> *arrayToSort;
    if (_isSearching) {
        arrayToSort = [NSMutableArray arrayWithArray:_filteredTracks];
    }
    else {
        arrayToSort = [NSMutableArray arrayWithArray:_tracks];
    }
    
    arrayToSort = (NSMutableArray *)[arrayToSort sortedArrayUsingComparator:^NSComparisonResult(SPTPlaylistTrack *a, SPTPlaylistTrack *b) {
        switch (event) {
            case JPSortByTrackName:
                return ascending ? [a.name caseInsensitiveCompare:b.name] : [b.name caseInsensitiveCompare:a.name];
                break;
                
            case JPSortByArtistName: {
                NSString *aArtistName = [(SPTPartialArtist *)a.artists.firstObject name];
                NSString *bArtistName = [(SPTPartialArtist *)b.artists.firstObject name];
                return ascending ? [aArtistName caseInsensitiveCompare:bArtistName] : [bArtistName caseInsensitiveCompare:aArtistName];
                break;
            }
                
            case JPSortByAlbumName:
                return ascending ? [a.album.name caseInsensitiveCompare:b.album.name] : [b.album.name caseInsensitiveCompare:a.album.name];
                break;
                
            case JPSortByAddDate:
                return ascending ? [a.addedAt compare:b.addedAt] : [b.addedAt compare:a.addedAt];
                break;
            
            case JPSortByTrackDuration:
                return ascending ? [@(a.duration) compare:@(b.duration)] : [@(b.duration) compare:@(a.duration)];
                break;
                
            default:
                break;
        }

        return NSOrderedSame;
    }];
    
    if (_isSearching) {
        [_filteredTracks removeAllObjects];
        _filteredTracks = [NSMutableArray arrayWithArray:arrayToSort];
    }
    else {
        [_tracks removeAllObjects];
        _tracks = [NSMutableArray arrayWithArray:arrayToSort];
    }
    
    [_list reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ((_isSearching && _filteredTracks.count) || (!_isSearching && _tracks.count)) {
        [_list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(![searchBar isFirstResponder]) { // clear text button tapped in search bar's textfield
        _isSearching = NO;
    }
    
    if (searchBar.text.length) {
        _isSearching = YES;
        [_filteredTracks removeAllObjects];
        
        NSString *text = searchBar.text;
        for (SPTPlaylistTrack *track in _tracks) {
            if ([track.name rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [track.album.name rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_filteredTracks addObject:track];
            }
            else {
                for (SPTPartialArtist *artist in track.artists) {
                    if ([artist.name rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [_filteredTracks addObject:track];
                        break;
                    }
                }
            }
        }
    }
    else {
        _isSearching = NO;
    }
    
    [_list reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearching = NO;
    searchBar.text = nil;
    [_list reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - keyboard event
- (void)UIKeyboardDidShow:(NSNotification*)notification {
    NSDictionary* info = notification.userInfo;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - PlayerViewHeight, 0.0);
    _list.contentInset = contentInsets;
    _list.scrollIndicatorInsets = contentInsets;
}

- (void)UIKeyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _list.contentInset = contentInsets;
    _list.scrollIndicatorInsets = contentInsets;
}

@end

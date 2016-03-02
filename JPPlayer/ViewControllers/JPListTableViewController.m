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

@property (strong, nonatomic) UIImageView *blurBackgroundImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray<SPTPlaylistTrack *> *SpotifyTracks;
@property (strong, nonatomic) NSMutableArray<SPTPlaylistTrack *> *filteredTracks;
@property (nonatomic) BOOL isSearching;

@end

@implementation JPListTableViewController
@synthesize topView = _topView;
@synthesize topViewHeight = _topViewHeight;
@synthesize list = _list;
@synthesize fakeHeaderView = _fakeHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _topView = super.topView;
    _topViewHeight = super.topViewHeight;
    _list = super.list;
    _fakeHeaderView = super.fakeHeaderView;
    
    _list.dataSource = self;
    _list.delegate = self;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _controlView = [[JPListControlView alloc] init];
    _controlView.delegate = self;
    _controlView.searchBar.delegate = self;
    [_fakeHeaderView addSubview:_controlView];
    [_controlView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_fakeHeaderView);
    }];
    
    UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
    
    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:placeHolder];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [_topView addSubview:_blurBackgroundImageView];
    [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topView);
    }];
    
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_blurBackgroundImageView addSubview:_blurEffectView];
    [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_blurBackgroundImageView);
    }];
    
    UIView *overlayView = [[UIView alloc] init];
    overlayView.layer.cornerRadius = 20.f;
    [_topView addSubview:overlayView];
    [overlayView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_blurBackgroundImageView.right);
        make.width.equalTo(_blurBackgroundImageView);
        make.bottom.greaterThanOrEqualTo(_topView).offset(-FakeHeaderHeight);
        make.height.equalTo(@(ContainerWidth - FakeHeaderHeight));
    }];
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:AnimationInterval delay:AnimationInterval options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [overlayView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_blurBackgroundImageView);
            make.top.greaterThanOrEqualTo(_blurBackgroundImageView);
            make.bottom.greaterThanOrEqualTo(_topView).offset(-FakeHeaderHeight);
            make.height.equalTo(@(ContainerWidth - FakeHeaderHeight));
        }];
        [self.view layoutIfNeeded];
    } completion:nil];
    
    
    _profileImageView = [[UIImageView alloc] initWithImage:placeHolder];
    _profileImageView.tintColor = [UIColor JPColor];
    [overlayView addSubview:_profileImageView];
    [_profileImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(overlayView);
        make.width.height.equalTo(@(200.f));
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Not available";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:24];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [overlayView addSubview:_titleLabel];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(overlayView);
        make.top.equalTo(_profileImageView.bottom).offset(8);
        make.height.equalTo(@(30));
    }];
    
    _SpotifyTracks = [[NSMutableArray alloc] init];
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
        
        [_SpotifyTracks addObjectsFromArray:playList.tracksForPlayback];
        [_list reloadData];
        
        [self checkNewPage:playList.firstTrackPage];
    }];
}

- (void)checkNewPage:(SPTListPage *)page {
    if (page.hasNextPage) {
        NSURLRequest *nextPageRequest = [page createRequestForNextPageWithAccessToken:[[[SPTAuth defaultInstance] session] accessToken] error:nil];
        [[SPTRequest sharedHandler] performRequest:nextPageRequest callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            
            SPTListPage *nextPage = [SPTListPage listPageFromData:data withResponse:response expectingPartialChildren:YES rootObjectKey:nil error:nil];
            
            [_SpotifyTracks addObjectsFromArray:nextPage.tracksForPlayback];
            [_list reloadData];
            
            if (nextPage.hasNextPage) {
                [self checkNewPage:nextPage];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *fakeHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, ContainerWidth)];
        [fakeHeader setBackgroundColor:[UIColor clearColor]];
        return fakeHeader;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return _topViewHeight;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) { // list section
        switch (_listType) {
            case SpotifyPlayList: {
                JPSpotifyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JPSpotifyListTableViewCellIdentifier];
                if (cell == nil) {
                    cell = [[JPSpotifyListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPSpotifyListTableViewCellIdentifier];
                }
                
                SPTPlaylistTrack *track = _isSearching ? [_filteredTracks objectAtIndex:indexPath.row] : [_SpotifyTracks objectAtIndex:indexPath.row];
                cell.titleLabel.text = track.name;
                SPTPartialArtist *artist0 = [track.artists objectAtIndex:0];
                cell.auxilaryLabel.text = [NSString stringWithFormat:@"%@ - %@", artist0.name, track.album.name];
                
                return cell;
                break;
            }
                
            default:
                break;
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    if (section == 1) {
        return _isSearching ? _filteredTracks.count : _SpotifyTracks.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (_listType) {
            case SpotifyPlayList:
                return JPSpotifyListTableCellHeight;
                break;
                
            default:
                return 0.f;
        }
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
            for (SPTPlaylistTrack *track in _SpotifyTracks) {
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
        arrayToSort = [NSMutableArray arrayWithArray:_SpotifyTracks];
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
        [_SpotifyTracks removeAllObjects];
        _SpotifyTracks = [NSMutableArray arrayWithArray:arrayToSort];
    }
    
    [_list reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ((_isSearching && _filteredTracks.count) || (!_isSearching && _SpotifyTracks.count)) {
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
        for (SPTPlaylistTrack *track in _SpotifyTracks) {
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

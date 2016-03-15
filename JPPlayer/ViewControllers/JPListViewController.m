//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPListViewController.h"
#import "JPListTableViewController.h"
#import "JPPlaylistCell.h"
#import "JPSpotifyPlayer.h"
#import "JPSpotifyListHeaderView.h"
#import "JPSpotifySession.h"

@interface JPListViewController () <UITableViewDataSource, UITableViewDelegate, JPSpotifyListHeaderDelegate>

@property (strong, nonatomic) UITableView *listsTableView;
@property (strong, nonatomic) SPTPlaylistList *SpotifyLists;
@property (strong, nonatomic) JPSpotifyListHeaderView *header;

@end

@implementation JPListViewController
@synthesize tableView = _tableView;
@synthesize containerList = _containerList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateSpotifySession) name:SpotifySessionStateChanged object:nil];
    
    _tableView = super.tableView;
    _containerList = super.containerList;
        
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _header = [[JPSpotifyListHeaderView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, 120)];
    _header.delegate = self;
    [[JPSpotifySession defaultInstance] checkSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [self validateSpotifySession];
}

- (void)validateSpotifySession {    
    SPTSession *session = [JPSpotifySession defaultInstance].session;
    
    switch ([JPSpotifySession defaultInstance].state) {
        case JPSpotifySessionValid: {
            SPTAudioStreamingController *player = [JPSpotifyPlayer player];
            if (!player.loggedIn) {
                _header.state = JPSpotifyHeaderLogging;
                
                [player loginWithSession:session callback:^(NSError *error) {
                    if (error) {
                        NSLog(@"Player login error: %@", error);
                        _header.state = JPSpotifyHeaderError;
                        return;
                    }
                    
                    _header.state = JPSpotifyHeaderRetrieving;
                    
                    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, SPTPlaylistList *lists) {
                        if (error) {
                            NSLog(@"Get playlist error: %@", error);
                            _header.state = JPSpotifyHeaderError;
                            return;
                        }
                        
                        _header.state = JPSpotifyHeaderDone;
                        
                        _SpotifyLists = lists;
                        [_tableView reloadData];
                    }];
                }];
            }
            
            break;
        }
            
        case JPSpotifySessionExpire:
            _header.state = JPSpotifyHeaderRenewing;
            break;
            
        default:
            _header.state = JPSpotifyHeaderNone;
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && _SpotifyLists != nil) {
        return _SpotifyLists.tracksForPlayback.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // spotify section
        JPPlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:JPPlaylistCellIdentifier];
        if (cell == nil) {
            cell = [[JPPlaylistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPPlaylistCellIdentifier];
        }
        
        SPTPartialPlaylist *partialPlayList = [[_SpotifyLists tracksForPlayback] objectAtIndex:indexPath.row];
        UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
        [cell.profileImageView setImageWithURL:partialPlayList.smallestImage.imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", partialPlayList.name];
        cell.auxilaryLabel.text = [@(partialPlayList.trackCount) stringValue];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) { // spotify header
        return _header;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 120.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return JPPlaylistCellHeight;
    }
    
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Spotify section
        for (JPContainerViewController *container in _containerList) {
            [container.view removeFromSuperview];
        }
        [_containerList removeAllObjects];
        
        JPListTableViewController *newSpotifyListVC = [[JPListTableViewController alloc] init];
        SPTPartialPlaylist *partialPlayList = [[_SpotifyLists tracksForPlayback] objectAtIndex:indexPath.row];
        newSpotifyListVC.information = partialPlayList;
        
        [self addOneContainer:newSpotifyListVC];
    }
}

#pragma mark - Other actions
- (void)refresh {
    _header.state = JPSpotifyHeaderRetrieving;
    
    [SPTPlaylistList playlistsForUserWithSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTPlaylistList *lists) {
        if (error) {
            NSLog(@"Get playlist error: %@", error);
            _header.state = JPSpotifyHeaderError;
            return;
        }
        
        _header.state = JPSpotifyHeaderDone;
        
        _SpotifyLists = lists;
        [_tableView reloadData];
    }];
}

@end

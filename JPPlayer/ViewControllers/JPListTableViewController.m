//
//  JPListTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPListTableViewController.h"
#import "JPSpotifyListTableViewCell.h"
#import "JPSpotifyPlayer.h"

@interface JPListTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIImageView *blurBackgroundImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic, strong) SPTRequestCallback playlistRequestCallback;
@property (strong, nonatomic) NSMutableArray *SpotifyTracks;

@end

@implementation JPListTableViewController
@synthesize topView = _topView;
@synthesize topViewHeight = _topViewHeight;
@synthesize list = _list;
@synthesize fakeHeaderView = _fakeHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _topView = super.topView;
    _topViewHeight = super.topViewHeight;
    _list = super.list;
    _fakeHeaderView = super.fakeHeaderView;
    
    _list.dataSource = self;
    _list.delegate = self;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *placeHolder = [[UIImage imageNamed:@"ic_blur_on_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:placeHolder];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
    _blurBackgroundImageView.tintColor = [UIColor redColor];
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
        make.left.right.equalTo(_blurBackgroundImageView);
        make.top.greaterThanOrEqualTo(_blurBackgroundImageView);
        make.bottom.greaterThanOrEqualTo(_topView).offset(-FakeHeaderHeight);
        make.height.equalTo(@(ContainerWidth - FakeHeaderHeight));
    }];
    
    _profileImageView = [[UIImageView alloc] initWithImage:placeHolder];
    _profileImageView.tintColor = [UIColor redColor];
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
    
    __weak typeof(self) weakSelf = self;
    _playlistRequestCallback = ^(NSError *error, SPTPlaylistSnapshot *playList) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        
        NSLog(@"new page");
        
        if (!playList.firstTrackPage.hasPreviousPage) {
            NSLog(@"First page");
            [weakSelf.blurBackgroundImageView setImageWithURL:[[playList largestImage] imageURL]];
            [weakSelf.profileImageView setImageWithURL:[[playList largestImage] imageURL]];
            weakSelf.titleLabel.text = playList.name;
        }
        
        [weakSelf.SpotifyTracks addObjectsFromArray:playList.tracksForPlayback];
        [weakSelf.list reloadData];
        
        if (playList.firstTrackPage.hasNextPage) {
            NSLog(@"Has next page");
            [SPTPlaylistSnapshot playlistWithURI:playList.firstTrackPage.nextPageURL session:[[SPTAuth defaultInstance] session] callback:weakSelf.playlistRequestCallback];
        }
    };
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
                
                SPTPlaylistTrack *track = [_SpotifyTracks objectAtIndex:indexPath.row];
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
        return _SpotifyTracks.count;
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
        SPTPlaylistTrack *track = [_SpotifyTracks objectAtIndex:indexPath.row];
        
        NSLog(@"About to play track: %@", track.name);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"aboutToPlayTrack" object:nil userInfo:@{@"track" : track}];
        
        [[JPSpotifyPlayer playerWithCliendId:[[SPTAuth defaultInstance] clientID]] playURIs:@[track.uri] fromIndex:0 callback:^(NSError *error) {
            if (error) {
                NSLog(@"Play back error: %@", error);
            }
            
            NSLog(@"Start playing %@", track.name);
        }];
    }
}

@end

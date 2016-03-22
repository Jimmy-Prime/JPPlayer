//
//  JPPopupMenuRootViewController.m
//  JPPlayer
//
//  Created by Prime on 3/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPPopupMenuRootViewController.h"
#import "JPPopupMenuPlaylistViewController.h"
#import "JPPopupMenuViewController.h"

#import "JPAlbumTableViewController.h"
#import "JPArtistCollectionViewController.h"

#import "JPSpotifySession.h"

@interface JPPopupMenuRootViewController ()

@property (strong, nonatomic) NSArray *menuCaptions;
@property (strong, nonatomic) NSArray *menuImageNames;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) JPPopupMenuPlaylistViewController *playlistVC;

@end

@implementation JPPopupMenuRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor JPBackgroundColor];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor JPColor];

    _menuCaptions = @[@"Add",
                      @"Add to Playlist",
                      @"Go to Album",
                      @"Go to Artist",
                      @"Share"];

    _menuImageNames = @[@"ic_add_circle_white_48pt",
                        @"ic_playlist_add_white_48pt",
                        @"ic_album_white_48pt",
                        @"ic_headset_white_48pt",
                        @"ic_share_white_48pt"];

    self.tableView.backgroundColor = [UIColor JPBackgroundColor];
    self.tableView.separatorColor = [UIColor JPSeparatorColor];
    
    _playlistVC = [[JPPopupMenuPlaylistViewController alloc] init];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuCaptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];

        UIView *backgroundColorView = [[UIView alloc] init];
        backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
        cell.selectedBackgroundView = backgroundColorView;

        cell.backgroundColor = [UIColor JPBackgroundColor];

        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:20];
    }

    cell.imageView.image = [UIImage imageNamed:_menuImageNames[indexPath.row]];

    cell.textLabel.text = _menuCaptions[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;

    switch (indexPath.row) {
        case 0: { // Add
            NSString *accessToken = [JPSpotifySession defaultInstance].session.accessToken;
#warning shorthand method not working
            NSURLRequest *req = [SPTYourMusic createRequestForCheckingIfSavedTracksContains:@[_track] forUserWithAccessToken:accessToken error:nil];
            [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([result isEqualToString:@"[ false ]"]) {
                    [SPTYourMusic saveTracks:@[_track] forUserWithAccessToken:accessToken callback:nil];

                    NSString *message = [NSString stringWithFormat:@"%@ is saved", _track.name];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Succeeded" message:message preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:defaultAction];

                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];

            [[JPPopupMenuViewController defaultInstance] dismissMenu];
            break;
        }

        case 1: // Add to Playlist
            _playlistVC.track = _track;
            [self.navigationController pushViewController:_playlistVC animated:YES];
            break;

        case 2: { // Go to Album
            JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
            newAlbumVC.information = _track.album;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newAlbumVC}];

            [[JPPopupMenuViewController defaultInstance] dismissMenu];
            break;
        }

        case 3: { // Go to Artist
            JPArtistCollectionViewController *newArtistVC = [[JPArtistCollectionViewController alloc] init];
            newArtistVC.information = _track.artists.firstObject;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newArtistVC}];

            [[JPPopupMenuViewController defaultInstance] dismissMenu];
            break;
        }

        case 4: // Share
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

@end

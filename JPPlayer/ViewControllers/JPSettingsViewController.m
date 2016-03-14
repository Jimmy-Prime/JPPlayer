//
//  JPSettingsViewController.m
//  JPPlayer
//
//  Created by Prime on 1/25/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSettingsViewController.h"
#import "JPSettingsColorViewController.h"
#import "JPSpotifySession.h"

@interface JPSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation JPSettingsViewController
@synthesize tableView = _tableView;
@synthesize containerList = _containerList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = super.tableView;
    _containerList = super.containerList;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
    }
    
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
    cell.selectedBackgroundView = backgroundColorView;
    
    cell.backgroundColor = [UIColor JPBackgroundColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = indexPath.row ? @"API testing" : @"Change theme color";
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // Change theme color
        for (JPContainerViewController *container in _containerList) {
            [container.view removeFromSuperview];
        }
        [_containerList removeAllObjects];
        
        JPSettingsColorViewController *containerVC = [[JPSettingsColorViewController alloc] init];
        [self addOneContainer:containerVC];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:AnimationInterval animations:^{
            JPContainerViewController *last = [_containerList lastObject];
            last.view.tag = Right;
            [last.dock uninstall];
            [last.right install];
            [self.view layoutIfNeeded];
        }];

    }
    else if (indexPath.row == 1) { // API testing
        SPTSession *session = [JPSpotifySession defaultInstance].session;
        NSURL *URI = [NSURL URLWithString:@"spotify:artist:0TnOYISbd1XYRBk9myaseg"];
        [SPTArtist artistWithURI:URI session:session callback:^(NSError *error, SPTArtist *artist) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            NSLog(@"Artist: %@", artist);

            [artist requestAlbumsOfType:SPTAlbumTypeAlbum withSession:session availableInTerritory:nil callback:^(NSError *error, id object) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSLog(@"Album: %@", object);
            }];

            [artist requestAlbumsOfType:SPTAlbumTypeSingle withSession:session availableInTerritory:nil callback:^(NSError *error, SPTListPage *page) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSLog(@"Single: %@", page);
                NSLog(@"%@", page.items);
            }];

            [artist requestAlbumsOfType:SPTAlbumTypeCompilation withSession:session availableInTerritory:nil callback:^(NSError *error, SPTListPage *page) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSLog(@"Compilation: %@", page);
                NSLog(@"%@", page.items);
            }];

            [artist requestAlbumsOfType:SPTAlbumTypeAppearsOn withSession:session availableInTerritory:nil callback:^(NSError *error, SPTListPage *page) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSLog(@"AppearsOn: %@", page);
                NSLog(@"%@", page.items);
            }];

            [artist requestTopTracksForTerritory:@"TW" withSession:session callback:^(NSError *error, id object) {
//                NSLog(@"Top Tracks: %@", object);
            }];

            [artist requestRelatedArtistsWithSession:session callback:^(NSError *error, id object) {
//                NSLog(@"Related Artists: %@", object);
            }];
        }];
    }
}

@end

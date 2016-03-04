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
    
    [self.view setBackgroundColor:[UIColor JPBackgroundColor]];
    
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
        [SPTBrowse requestFeaturedPlaylistsForCountry:@"TW" limit:50 offset:0 locale:@"" timestamp:nil accessToken:[JPSpotifySession defaultInstance].session.accessToken callback:^(NSError *error, SPTFeaturedPlaylistList *playlistList) {
            
            NSLog(@"RAW DATA: %@", playlistList);
            
            NSLog(@"MESSAGE: %@", playlistList.message);
            
            NSLog(@"%@", playlistList.items);
            
        }];
    }
}

@end

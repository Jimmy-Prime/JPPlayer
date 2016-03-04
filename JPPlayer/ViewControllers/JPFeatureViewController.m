//
//  JPFeatureViewController.m
//  JPPlayer
//
//  Created by Prime on 3/4/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPFeatureViewController.h"
#import "JPSpotifyFeatureCollectionViewCell.h"
#import "JPListTableViewController.h"
#import "JPSpotifySession.h"

@interface JPFeatureViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) SPTFeaturedPlaylistList *playlistList;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UICollectionView *featureList;
@property (nonatomic) CGSize cellSize;

@end

@implementation JPFeatureViewController
@synthesize containerList = _containerList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _containerList = super.containerList;
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.backgroundColor = [UIColor JPSelectedCellColor];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.text = @"Not Available";
    [self.view addSubview:_messageLabel];
    [_messageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(FakeHeaderHeight));
    }];
    
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.itemSize = _cellSize = (CGSize){210.f, 250.f};
    
    _featureList = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    _featureList.backgroundColor = [UIColor clearColor];
    _featureList.showsHorizontalScrollIndicator = NO;
    [_featureList registerClass:[JPSpotifyFeatureCollectionViewCell class] forCellWithReuseIdentifier:JPSpotifyFeatureCollectionViewIdentifier];
    _featureList.dataSource = self;
    _featureList.delegate = self;
    [self.view addSubview:_featureList];
    [_featureList makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_messageLabel.bottom);
        make.left.equalTo(self.view).offset(15.f);
        make.right.equalTo(self.view).offset(-15.f);
        make.height.equalTo(@(_cellSize.height));
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [SPTBrowse requestFeaturedPlaylistsForCountry:@"TW" limit:50 offset:0 locale:@"" timestamp:nil accessToken:[JPSpotifySession defaultInstance].session.accessToken callback:^(NSError *error, SPTFeaturedPlaylistList *playlistList) {
        self.playlistList = playlistList;
    }];
}

- (void)setPlaylistList:(SPTFeaturedPlaylistList *)playlistList {
    _playlistList = playlistList;
    
    _messageLabel.text = playlistList.message;
    [_featureList reloadData];
}

#pragma make - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_playlistList) {
        return _playlistList.items.count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPSpotifyFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPSpotifyFeatureCollectionViewIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[JPSpotifyFeatureCollectionViewCell alloc] init];
    }
    
    SPTPartialPlaylist *partialList = _playlistList.items[indexPath.row];
    [cell.profileImageView setImageWithURL:partialList.largestImage.imageURL placeholderImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
    cell.titleLabel.text = partialList.name;
    
    return cell;
}

#pragma make - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (JPContainerViewController *container in _containerList) {
        [container.view removeFromSuperview];
    }
    [_containerList removeAllObjects];
    
    JPListTableViewController *newSpotifyListVC = [[JPListTableViewController alloc] init];
    newSpotifyListVC.listType = SpotifyPlayList;
    SPTPartialPlaylist *partialPlayList = _playlistList.items[indexPath.row];
    newSpotifyListVC.information = partialPlayList;
    
    [self addOneContainer:newSpotifyListVC];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:AnimationInterval animations:^{
        JPContainerViewController *last = [_containerList lastObject];
        last.view.tag = Right;
        [last.dock uninstall];
        [last.right install];
        [self.view layoutIfNeeded];
    }];
}

@end

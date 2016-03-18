//
//  JPFeatureViewController.m
//  JPPlayer
//
//  Created by Prime on 3/4/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPBrowseViewController.h"
#import "JPCollectionViewCell.h"
#import "JPListTableViewController.h"
#import "JPAlbumTableViewController.h"
#import "JPSpotifySession.h"

@interface JPBrowseViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UILabel *featureMessageLabel;
@property (strong, nonatomic) SPTFeaturedPlaylistList *featureListList;
@property (strong, nonatomic) UICollectionView *featureListCollectionView;
@property (nonatomic) CGSize featureCellSize;

@property (strong, nonatomic) UILabel *NewReleaseLabel;
@property (strong, nonatomic) NSMutableArray *NewReleaseList;
@property (strong, nonatomic) UICollectionView *NewReleaseCollectionView;
@property (nonatomic) CGSize NewReleaseCellSize;

@end

@implementation JPBrowseViewController
@synthesize containerList = _containerList;

- (void)viewDidLoad {
    [super viewDidLoad];

    _containerList = super.containerList;
    
    _featureMessageLabel = [[UILabel alloc] init];
    _featureMessageLabel.backgroundColor = [UIColor JPSeparatorColor];
    _featureMessageLabel.textColor = [UIColor whiteColor];
    _featureMessageLabel.textAlignment = NSTextAlignmentCenter;
    _featureMessageLabel.text = @"Not Available";
    [self.view addSubview:_featureMessageLabel];
    [_featureMessageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight));
    }];

    UICollectionViewFlowLayout *featureFlow = [[UICollectionViewFlowLayout alloc] init];
    featureFlow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    featureFlow.itemSize = _featureCellSize = (CGSize){210.f, 250.f};
    
    _featureListCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:featureFlow];
    _featureListCollectionView.backgroundColor = [UIColor JPBackgroundColor];
    _featureListCollectionView.showsHorizontalScrollIndicator = NO;
    [_featureListCollectionView registerClass:[JPCollectionViewCell class] forCellWithReuseIdentifier:JPCollectionViewCellIdentifier];
    _featureListCollectionView.dataSource = self;
    _featureListCollectionView.delegate = self;
    [self.view addSubview:_featureListCollectionView];
    [_featureListCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_featureMessageLabel.bottom);
        make.left.equalTo(self.view).offset(15.f);
        make.right.equalTo(self.view).offset(-15.f);
        make.height.equalTo(@(_featureCellSize.height));
    }];

    _NewReleaseLabel = [[UILabel alloc] init];
    _NewReleaseLabel.backgroundColor = [UIColor JPSeparatorColor];
    _NewReleaseLabel.textColor = [UIColor whiteColor];
    _NewReleaseLabel.textAlignment = NSTextAlignmentCenter;
    _NewReleaseLabel.text = @"New Release";
    [self.view addSubview:_NewReleaseLabel];
    [_NewReleaseLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_featureListCollectionView.bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight));
    }];

    UICollectionViewFlowLayout *NewReleaseFlow = [[UICollectionViewFlowLayout alloc] init];
    NewReleaseFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
    NewReleaseFlow.itemSize = _NewReleaseCellSize = (CGSize){160.f, 190.f};

    _NewReleaseCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:NewReleaseFlow];
    _NewReleaseCollectionView.backgroundColor = [UIColor clearColor];
    [_NewReleaseCollectionView registerClass:[JPCollectionViewCell class] forCellWithReuseIdentifier:JPCollectionViewCellIdentifier];
    _NewReleaseCollectionView.dataSource = self;
    _NewReleaseCollectionView.delegate = self;
    [self.view addSubview:_NewReleaseCollectionView];
    [_NewReleaseCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_NewReleaseLabel.bottom);
        make.bottom.left.right.equalTo(self.view);
    }];

    _NewReleaseList = [[NSMutableArray alloc] init];

    [SPTBrowse requestFeaturedPlaylistsForCountry:@"TW" limit:50 offset:0 locale:@"" timestamp:nil accessToken:[JPSpotifySession defaultInstance].session.accessToken callback:^(NSError *error, SPTFeaturedPlaylistList *playlistList) {
        _featureListList = playlistList;
        _featureMessageLabel.text = playlistList.message;
        [_featureListCollectionView reloadData];
    }];

#warning shorthand method not working
    NSURLRequest *req = [SPTBrowse createRequestForNewReleasesInCountry:@"TW" limit:50 offset:0 accessToken:[JPSpotifySession defaultInstance].session.accessToken error:nil];
    [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
        SPTListPage *page = [SPTBrowse newReleasesFromData:data withResponse:response error:&error];
        [_NewReleaseList addObjectsFromArray:page.items];
        [_NewReleaseCollectionView reloadData];
        [self checkNextPage:page];
    }];
}

- (void)checkNextPage:(SPTListPage *)page {
    if ([page hasNextPage]) {
        [page requestNextPageWithSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTListPage *nextPage) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            [_NewReleaseList addObjectsFromArray:nextPage.items];
            [_NewReleaseCollectionView reloadData];
            [self checkNextPage:nextPage];
        }];
    }
}

#pragma make - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _featureListCollectionView && _featureListList) {
        return _featureListList.items.count;
    }

    if (collectionView == _NewReleaseCollectionView && _NewReleaseList) {
        return _NewReleaseList.count;
    }

    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JPCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[JPCollectionViewCell alloc] init];
    }

    if (collectionView == _featureListCollectionView) {
        SPTPartialPlaylist *partialList = _featureListList.items[indexPath.row];
        [cell.profileImageView setImageWithURL:[partialList imageClosestToSize:_featureCellSize].imageURL placeholderImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
        cell.titleLabel.text = partialList.name;
    }
    else if (collectionView == _NewReleaseCollectionView) {
        SPTPartialAlbum *partialAlbum = _NewReleaseList[indexPath.row];
        [cell.profileImageView setImageWithURL:[partialAlbum imageClosestToSize:_NewReleaseCellSize].imageURL placeholderImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
        cell.titleLabel.text = partialAlbum.name;
    }
    
    return cell;
}

#pragma make - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (JPContainerViewController *container in _containerList) {
        [container.view removeFromSuperview];
    }
    [_containerList removeAllObjects];

    if (collectionView == _featureListCollectionView) {
        JPListTableViewController *newListVC = [[JPListTableViewController alloc] init];
        SPTPartialPlaylist *partialPlayList = _featureListList.items[indexPath.row];
        newListVC.information = partialPlayList;
        [self addOneContainer:newListVC];
    }
    else if (collectionView == _NewReleaseCollectionView) {
        JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
        SPTPartialAlbum *partialAlbum = _NewReleaseList[indexPath.row];
        newAlbumVC.information = partialAlbum;
        [self addOneContainer:newAlbumVC];
    }

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

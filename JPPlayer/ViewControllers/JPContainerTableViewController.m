//
//  JPContainerTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/18/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPContainerTableViewController.h"
#import "JPSpotifySession.h"

@interface JPContainerTableViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@end

@implementation JPContainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _topViewHeight = ContainerWidth;
    
    _topView = [[UIView alloc] init];
    _topView.clipsToBounds = YES;
    [self.view addSubview:_topView];
    [_topView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(_topViewHeight));
    }];
    
    _list = [[UITableView alloc] init];
    _list.dataSource = self;
    _list.delegate = self;
    _list.backgroundColor = [UIColor clearColor];
    _list.separatorColor = [UIColor JPSeparatorColor];
    [self.view addSubview:_list];
    [_list makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _fakeHeaderView = [[UIView alloc] init];
    _fakeHeaderView.backgroundColor = [UIColor JPFakeHeaderColor];
    [self.view addSubview:_fakeHeaderView];
    [_fakeHeaderView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(_topView);
        make.height.equalTo(@(FakeHeaderHeight));
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

    _tracks = [[NSMutableArray alloc] init];
}

- (void)checkNewPage:(SPTListPage *)page {
    if (page.hasNextPage) {
        [page requestNextPageWithSession:[JPSpotifySession defaultInstance].session callback:^(NSError *error, SPTListPage *nextPage) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }

            [_tracks addObjectsFromArray:nextPage.tracksForPlayback];
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
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 100 : 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _topViewHeight = ContainerWidth - scrollView.contentOffset.y;
    if (_topViewHeight < FakeHeaderHeight) {
        _topViewHeight = FakeHeaderHeight;
    }
    
    [_topView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(_topViewHeight));
    }];
}

@end

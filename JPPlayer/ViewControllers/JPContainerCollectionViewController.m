//
//  JPContainerCollectionViewController.m
//  JPPlayer
//
//  Created by Prime on 3/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPContainerCollectionViewController.h"

@interface JPContainerCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation JPContainerCollectionViewController

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

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = 20.f;
    flow.minimumLineSpacing = 20.f;

    _list = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    [_list registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JPContainerCollectionViewHeader"];
    _list.backgroundColor = [UIColor clearColor];
    _list.dataSource = self;
    _list.delegate = self;
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
    _profileImageView.contentMode = UIViewContentModeScaleAspectFit;
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section ? 100 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[UICollectionViewCell alloc] init];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JPContainerCollectionViewHeader" forIndexPath:indexPath];
        return header;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return (UIEdgeInsets){0, 20, 0, 20};
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return section ? (CGSize){ContainerWidth, FakeHeaderHeight} : (CGSize){ContainerWidth, ContainerWidth};
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (ContainerWidth - 60.f) / 2.f;
    return (CGSize){width, width + 40.f};
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

//
//  JPCoverScrollViewController.m
//  JPPlayer
//
//  Created by Prime on 1/8/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPCoverScrollViewController.h"
#import "JPSpotifyPlayer.h"

@interface JPCoverScrollViewController () <UIScrollViewDelegate>

@property NSUInteger currentPage;
@property (strong, nonatomic) UIScrollView *coverScrollView;
@property (strong, nonatomic) NSMutableArray *coverImageList;

@end

@implementation JPCoverScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangeToTrack:) name:SpotifyDidChangeToTrack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidCreateRandomArray) name:SpotifyDidCreateRandomArray object:nil];

    _coverScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_coverScrollView];
    [_coverScrollView setPagingEnabled:YES];
    [_coverScrollView setShowsHorizontalScrollIndicator:NO];
    [_coverScrollView setShowsVerticalScrollIndicator:NO];
    [_coverScrollView setScrollsToTop:NO];
    [_coverScrollView setDelegate:self];
    [_coverScrollView setClipsToBounds:NO];
    [_coverScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
    
    _coverImageList = [[NSMutableArray alloc] init];
    for (int i=0; i<5; ++i) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
        view.image = [UIImage imageNamed:@"PlaceHolder.jpg"];
        view.contentMode = UIViewContentModeScaleToFill;
        [_coverScrollView addSubview:view];
        [_coverImageList addObject:view];
    }
    
    _currentPage = 2;
}

- (void)viewDidLayoutSubviews {
    if (_landscape) {
        [_coverScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), _coverImageList.count * CGRectGetHeight(self.view.frame))];
        CGFloat interval = CGRectGetHeight(self.view.frame) - CoverLength;
        for (int i=0; i<_coverImageList.count; ++i) {
            UIView *view = [_coverImageList objectAtIndex:i];
            CGRect frame = view.frame;
            frame.origin.x = 0.f;
            frame.origin.y = (CoverLength + interval) * (CGFloat)i + interval / 2.f;
            view.frame = frame;
        }
        
        CGRect bounds = _coverScrollView.bounds;
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _currentPage;
        [_coverScrollView scrollRectToVisible:bounds animated:NO];
    }
    else {
        [_coverScrollView setContentSize:CGSizeMake(_coverImageList.count * CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        CGFloat interval = CGRectGetWidth(self.view.frame) - CoverLength;
        for (int i=0; i<_coverImageList.count; ++i) {
            UIView *view = [_coverImageList objectAtIndex:i];
            CGRect frame = view.frame;
            frame.origin.x = (CoverLength + interval) * (CGFloat)i + interval / 2.f;;
            frame.origin.y = 0.f;
            view.frame = frame;
        }
        
        CGRect bounds = _coverScrollView.bounds;
        bounds.origin.x = CGRectGetWidth(bounds) * _currentPage;
        bounds.origin.y = 0.f;
        [_coverScrollView scrollRectToVisible:bounds animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger newPage;
    if (_landscape) {
        CGFloat pageLength = CGRectGetHeight(self.view.frame);
        newPage = floor((scrollView.contentOffset.y - pageLength / 2.f) / pageLength) + 1;
    }
    else {
        CGFloat pageLength = CGRectGetWidth(self.view.frame);
        newPage = floor((scrollView.contentOffset.x - pageLength / 2.f) / pageLength) + 1;
    }
    
    if (newPage < _currentPage) {
        [[JPSpotifyPlayer defaultInstance] playPrevious];
    }
    else if (newPage > _currentPage) {
        [[JPSpotifyPlayer defaultInstance] playNext];
    }
    
    _currentPage = newPage;
}

- (void)spotifyDidChangeToTrack:(NSNotification *)notification {
    _currentPage = 2;
    CGRect bounds = _coverScrollView.bounds;
    if (_landscape) {
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _currentPage;
    }
    else {
        bounds.origin.x = CGRectGetWidth(bounds) * _currentPage;
        bounds.origin.y = 0.f;
    }
    [_coverScrollView scrollRectToVisible:bounds animated:NO];
    
    [self spotifyDidCreateRandomArray];
}

- (void)spotifyDidCreateRandomArray {
    NSInteger index = [JPSpotifyPlayer defaultInstance].index;
    for (int i=0; i<_coverImageList.count; ++i) {
        UIImageView *view = [_coverImageList objectAtIndex:i];
        
        NSUInteger count = [JPSpotifyPlayer defaultInstance].URIs.count;
        if ([JPSpotifyPlayer defaultInstance].playbackState == JPSpotifyPlaybackNone && (index + i - 2 < 0 || index + i - 2 >= count)) {
            [view setImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
        }
        else {
            NSURL *URI = [JPSpotifyPlayer defaultInstance].URIs[(index + i - 2) % count];
            [SPTTrack trackWithURI:URI session:[SPTAuth defaultInstance].session callback:^(NSError *error, SPTTrack *track) {
                [view setImageWithURL:track.album.largestCover.imageURL];
            }];
        }
    }
}

@end

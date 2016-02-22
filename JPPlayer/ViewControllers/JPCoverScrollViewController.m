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
#import "JPCoverImageView.h"

@interface JPCoverScrollViewController () <UIScrollViewDelegate>

@property NSUInteger midPage;
@property (strong, nonatomic) UIScrollView *coverScrollView;

@end

@implementation JPCoverScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangeToTrack:) name:SpotifyDidChangeToTrack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidChangePlaybackMode) name:SpotifyDidChangePlaybackMode object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyShowNextTrackAnimation) name:SpotifyShowNextTrackAnimation object:nil];

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
    
    _midPage = 2;
    for (int i=0; i<2*_midPage+1; ++i) {
        JPCoverImageView *view = [[JPCoverImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
        view.image = [UIImage imageNamed:@"PlaceHolder.jpg"];
        view.contentMode = UIViewContentModeScaleToFill;
        [_coverScrollView addSubview:view];
    }
}

- (void)viewDidLayoutSubviews {
    if (_landscape) {
        [_coverScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), _coverScrollView.subviews.count * CGRectGetHeight(self.view.frame))];
        CGFloat interval = CGRectGetHeight(self.view.frame) - CoverLength;
        for (int i=0; i<_coverScrollView.subviews.count; ++i) {
            UIView *view = _coverScrollView.subviews[i];
            CGRect frame = view.frame;
            frame.origin.x = 0.f;
            frame.origin.y = (CoverLength + interval) * (CGFloat)i + interval / 2.f;
            view.frame = frame;
        }
        
        CGRect bounds = _coverScrollView.bounds;
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _midPage;
        [_coverScrollView scrollRectToVisible:bounds animated:NO];
    }
    else {
        [_coverScrollView setContentSize:CGSizeMake(_coverScrollView.subviews.count * CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        CGFloat interval = CGRectGetWidth(self.view.frame) - CoverLength;
        for (int i=0; i<_coverScrollView.subviews.count; ++i) {
            UIView *view = _coverScrollView.subviews[i];
            CGRect frame = view.frame;
            frame.origin.x = (CoverLength + interval) * (CGFloat)i + interval / 2.f;;
            frame.origin.y = 0.f;
            view.frame = frame;
        }
        
        CGRect bounds = _coverScrollView.bounds;
        bounds.origin.x = CGRectGetWidth(bounds) * _midPage;
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
    
    if (newPage < _midPage) {
        [[JPSpotifyPlayer defaultInstance] playPrevious];
        
        for (NSUInteger i=_coverScrollView.subviews.count-1; i>0; --i) {
            JPCoverImageView *destination = _coverScrollView.subviews[i];
            JPCoverImageView *source = _coverScrollView.subviews[i-1];
            [destination setWith:source];
        }
    }
    else if (newPage > _midPage) {
        [[JPSpotifyPlayer defaultInstance] playNext];
        
        for (NSUInteger i=0; i<_coverScrollView.subviews.count-1; ++i) {
            JPCoverImageView *destination = _coverScrollView.subviews[i];
            JPCoverImageView *source = _coverScrollView.subviews[i+1];
            [destination setWith:source];
        }
    }
    
    CGRect bounds = _coverScrollView.bounds;
    if (_landscape) {
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _midPage;
    }
    else {
        bounds.origin.x = CGRectGetWidth(bounds) * _midPage;
        bounds.origin.y = 0.f;
    }
    [_coverScrollView scrollRectToVisible:bounds animated:NO];
}

- (void)spotifyDidChangeToTrack:(NSNotification *)notification {
    [self spotifyDidChangePlaybackMode];
    
    _midPage = 2;
    CGRect bounds = _coverScrollView.bounds;
    if (_landscape) {
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _midPage;
    }
    else {
        bounds.origin.x = CGRectGetWidth(bounds) * _midPage;
        bounds.origin.y = 0.f;
    }
    [_coverScrollView scrollRectToVisible:bounds animated:NO];
}

- (void)spotifyDidChangePlaybackMode {
    NSInteger index = [JPSpotifyPlayer defaultInstance].index;
    for (int i=0; i<_coverScrollView.subviews.count; ++i) {
        JPCoverImageView *view = _coverScrollView.subviews[i];
        
        NSUInteger count = [JPSpotifyPlayer defaultInstance].URIs.count;
        if ([JPSpotifyPlayer defaultInstance].playbackState == JPSpotifyPlaybackNone && (index + i - 2 < 0 || index + i - 2 >= count)) {
            [view setImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
            view.spotifyURI = nil;
        }
        else {
            NSURL *URI = [JPSpotifyPlayer defaultInstance].URIs[(index + i - 2) % count];
            if (view.spotifyURI != URI) {
                view.spotifyURI = URI;
                [SPTTrack trackWithURI:URI session:[SPTAuth defaultInstance].session callback:^(NSError *error, SPTTrack *track) {
                    [view setImageWithURL:track.album.largestCover.imageURL];
                }];
            }
        }
    }
}

- (void)spotifyShowNextTrackAnimation {
    CGRect bounds = _coverScrollView.bounds;
    if (_landscape) {
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * (_midPage + 1);
    }
    else {
        bounds.origin.x = CGRectGetWidth(bounds) * (_midPage + 1);
        bounds.origin.y = 0.f;
    }
    [_coverScrollView scrollRectToVisible:bounds animated:YES];
        
    for (NSUInteger i=0; i<_coverScrollView.subviews.count-1; ++i) {
        JPCoverImageView *destination = _coverScrollView.subviews[i];
        JPCoverImageView *source = _coverScrollView.subviews[i+1];
        [destination setWith:source];
    }
    
    bounds = _coverScrollView.bounds;
    if (_landscape) {
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _midPage;
    }
    else {
        bounds.origin.x = CGRectGetWidth(bounds) * _midPage;
        bounds.origin.y = 0.f;
    }
    [_coverScrollView scrollRectToVisible:bounds animated:NO];
}

@end

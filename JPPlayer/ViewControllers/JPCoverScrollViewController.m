//
//  JPCoverScrollViewController.m
//  JPPlayer
//
//  Created by Prime on 1/8/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPCoverScrollViewController.h"

@interface JPCoverScrollViewController () <UIScrollViewDelegate>

@property NSUInteger currentPage;
@property (strong, nonatomic) UIScrollView *coverScrollView;
@property (strong, nonatomic) NSMutableArray *coverImageList;

@end

@implementation JPCoverScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _coverScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_coverScrollView];
    [_coverScrollView setPagingEnabled:YES];
    [_coverScrollView setShowsHorizontalScrollIndicator:NO];
    [_coverScrollView setShowsVerticalScrollIndicator:NO];
    [_coverScrollView setScrollsToTop:NO];
    [_coverScrollView setDelegate:self];
    [_coverScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
    
    _coverImageList = [[NSMutableArray alloc] init];
    for (int i=0; i<5; ++i) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
        view.image = [UIImage imageNamed:@"cover.jpg"];
        view.contentMode = UIViewContentModeScaleToFill;
        [_coverScrollView addSubview:view];
        [_coverImageList addObject:view];
    }
}

- (void)viewDidLayoutSubviews {
    if (_landscape) {
        [_coverScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), _coverImageList.count * CGRectGetHeight(self.view.frame))];
        for (int i=0; i<_coverImageList.count; ++i) {
            UIView *view = [_coverImageList objectAtIndex:i];
            CGRect frame = view.frame;
            frame.origin.x = 0.f;
            frame.origin.y = CGRectGetHeight(self.view.frame) * (CGFloat)i + CGRectGetHeight(self.view.frame) / 2.f - 300;
            view.frame = frame;
        }
        
        CGRect bounds = _coverScrollView.bounds;
        bounds.origin.x = 0.f;
        bounds.origin.y = CGRectGetHeight(bounds) * _currentPage;
        [_coverScrollView scrollRectToVisible:bounds animated:NO];
    }
    else {
        [_coverScrollView setContentSize:CGSizeMake(_coverImageList.count * CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        for (int i=0; i<_coverImageList.count; ++i) {
            UIView *view = [_coverImageList objectAtIndex:i];
            CGRect frame = view.frame;
            frame.origin.x = CGRectGetWidth(self.view.frame) * (CGFloat)i + CGRectGetWidth(self.view.frame) / 2.f - 300;
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
    if (_landscape) {
        CGFloat pageLength = CGRectGetHeight(self.view.frame);
        _currentPage = floor((scrollView.contentOffset.y - pageLength / 2.f) / pageLength) + 1;
    }
    else {
        CGFloat pageLength = CGRectGetWidth(self.view.frame);
        _currentPage = floor((scrollView.contentOffset.x - pageLength / 2.f) / pageLength) + 1;
    }
}

@end

//
//  JPListControlView.m
//  JPPlayer
//
//  Created by Prime on 2/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPListControlView.h"

@interface JPListControlView()

@property (strong, nonatomic) JPListControlCell *sortByTrackName;
@property (strong, nonatomic) JPListControlCell *sortByArtistName;
@property (strong, nonatomic) JPListControlCell *sortByAlbumName;
@property (strong, nonatomic) JPListControlCell *sortByAddDate;
@property (strong, nonatomic) JPListControlCell *sortByTrackDuration;

@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) JPListControlCell *lastHitCell;

@property (strong, nonatomic) UIView *firstSection;
@property (strong, nonatomic) UIView *secondSection;
@property (strong, nonatomic) JPListControlCell *more;
@property (strong, nonatomic) JPListControlCell *less;
@property (strong, nonatomic) MASConstraint *firstLeft;
@property (strong, nonatomic) MASConstraint *secondLeft;

@end

@implementation JPListControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        
        // first section
        _firstSection = [[UIView alloc] init];
        [self addSubview:_firstSection];
        [_firstSection makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(self);
            _firstLeft = make.left.equalTo(self);
        }];
        
        UIImage *alphaImage = [[UIImage imageNamed:@"ic_sort_by_alpha_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *sortImage = [[UIImage imageNamed:@"ic_sort_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *moreImage = [[UIImage imageNamed:@"ic_keyboard_arrow_left_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        CGFloat width = 65.f;
        CGFloat height = 80.f;
        CGFloat interval = 10.f;
        
        _sortByTrackName = [[JPListControlCell alloc] initWithImage:alphaImage andCaption:@"SONG"];
        _sortByTrackName.layer.cornerRadius = 5.f;
        [_sortByTrackName addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_sortByTrackName];
        [_sortByTrackName makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.left.equalTo(_firstSection).offset(interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _sortByArtistName = [[JPListControlCell alloc] initWithImage:alphaImage andCaption:@"ARTIST"];
        _sortByArtistName.layer.cornerRadius = 5.f;
        [_sortByArtistName addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_sortByArtistName];
        [_sortByArtistName makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.left.equalTo(_sortByTrackName.right).offset(interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _sortByAlbumName = [[JPListControlCell alloc] initWithImage:alphaImage andCaption:@"ALBUM"];
        _sortByAlbumName.layer.cornerRadius = 5.f;
        [_sortByAlbumName addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_sortByAlbumName];
        [_sortByAlbumName makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.left.equalTo(_sortByArtistName.right).offset(interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _sortByAddDate = [[JPListControlCell alloc] initWithImage:sortImage andCaption:@"Date"];
        _sortByAddDate.layer.cornerRadius = 5.f;
        [_sortByAddDate addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_sortByAddDate];
        [_sortByAddDate makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.left.equalTo(_sortByAlbumName.right).offset(interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _sortByTrackDuration = [[JPListControlCell alloc] initWithImage:sortImage andCaption:@"DURATION"];
        _sortByTrackDuration.layer.cornerRadius = 5.f;
        [_sortByTrackDuration addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_sortByTrackDuration];
        [_sortByTrackDuration makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.left.equalTo(_sortByAddDate.right).offset(interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _more = [[JPListControlCell alloc] initWithImage:moreImage andCaption:@""];
        [_more addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
        [_firstSection addSubview:_more];
        [_more makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstSection);
            make.right.equalTo(_firstSection).offset(-interval);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = [UIColor redColor];
        [_firstSection addSubview:_indicatorView];
        
        // second section
        _secondSection = [[UIView alloc] init];
        _secondSection.alpha = 0.f;
        [self addSubview:_secondSection];
        [_secondSection makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            _secondLeft = make.left.equalTo(self);
            make.width.height.equalTo(self);
        }];
        [_secondLeft uninstall];
        
        UIImage *lessImage = [[UIImage imageNamed:@"ic_keyboard_arrow_right_white_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        _less = [[JPListControlCell alloc] initWithImage:lessImage andCaption:@""];
        [_less addTarget:self action:@selector(less:) forControlEvents:UIControlEventTouchUpInside];
        [_secondSection addSubview:_less];
        [_less makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_secondSection);
            make.left.equalTo(_secondSection).offset(interval);
            make.left.equalTo(_more).priorityHigh();
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
        }];
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Search";
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.tintColor = [UIColor redColor];
        _searchBar.showsCancelButton = YES;
        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor redColor]];
        [_secondSection addSubview:_searchBar];
        [_searchBar makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_secondSection);
            make.left.equalTo(_less.right).offset(interval);
            make.right.equalTo(_secondSection).offset(-interval);
            make.height.equalTo(@(height));
        }];
    }
    
    return self;
}

- (void)controlTapped:(JPListControlCell *)cell {
    cell.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.8f];
    if (_lastHitCell && _lastHitCell != cell) {
        _lastHitCell.backgroundColor = [UIColor clearColor];
    }
    
    JPControlEvent event;
    if (cell == _sortByTrackName) {
        event = JPSortByTrackName;
    }
    else if (cell == _sortByArtistName) {
        event = JPSortByArtistName;
    }
    else if (cell == _sortByAlbumName) {
        event = JPSortByAlbumName;
    }
    else if (cell == _sortByAddDate) {
        event = JPSortByAddDate;
    }
    else if (cell == _sortByTrackDuration) {
        event = JPSortByTrackDuration;
    }
    
    [_indicatorView remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(55.f));
        make.height.equalTo(@(3.f));
        make.centerX.equalTo(cell);
        if (_lastHitCell == cell && _lastHitCell.tag == 0) {
            make.bottom.equalTo(self);
            _lastHitCell.tag = 1;
            [self.delegate sendControlEvent:event ascending:NO];
        }
        else {
            make.top.equalTo(self);
            _lastHitCell.tag = 0;
            [self.delegate sendControlEvent:event ascending:YES];
        }
    }];
    
    _lastHitCell = cell;
}

- (void)more:(UIControl *)control {
    [UIView animateWithDuration:0.3f animations:^{
        _more.alpha = 0.f;
        _less.alpha = 1.f;
        _secondSection.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            [_firstLeft uninstall];
            [_secondLeft install];
            [self layoutIfNeeded];
        }];
    }];
}

- (void)less:(UIControl *)control {
    [UIView animateWithDuration:0.3f animations:^{
        [_firstLeft install];
        [_secondLeft uninstall];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            _more.alpha = 1.f;
            _less.alpha = 0.f;
            _secondSection.alpha = 0.f;
        }];
    }];
}

@end

//
//  JPListControlView.h
//  JPPlayer
//
//  Created by Prime on 2/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPListControlCell.h"

typedef enum {
    JPSortByTrackName,
    JPSortByArtistName,
    JPSortByAlbumName,
    JPSortByAddDate,
    JPSortByTrackDuration
} JPControlEvent;

@protocol JPListControlDelegate

- (void)sendControlEvent:(JPControlEvent)event ascending:(BOOL)ascending;

@end

@interface JPListControlView : UIView

@property (nonatomic) id <JPListControlDelegate> delegate;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

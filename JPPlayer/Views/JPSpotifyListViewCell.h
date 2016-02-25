//
//  JPSpotifyListTableViewCell.h
//  JPPlayer
//
//  Created by Prime on 1/27/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPSpotifyListViewCellIdentifier @"SpotifyPlaylistCell"
static const CGFloat JPSpotifyListCellHeight = 70.f;

@interface JPSpotifyListViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;

@end

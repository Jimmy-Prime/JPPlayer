//
//  JPSpotifyListTableViewCell.h
//  JPPlayer
//
//  Created by Prime on 1/27/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPPlaylistCellIdentifier @"JPPlaylistCell"
static const CGFloat JPPlaylistCellHeight = 70.f;

@interface JPPlaylistCell : UITableViewCell

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;

@end

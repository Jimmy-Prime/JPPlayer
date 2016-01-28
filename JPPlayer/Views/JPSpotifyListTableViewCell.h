//
//  JPSpotifyListTableViewCell.h
//  JPPlayer
//
//  Created by Prime on 1/27/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPSpotifyListTableViewCellIdentifier @"SpotifyListCell"
static const CGFloat JPSpotifyListCellHeight = 64.f;

@interface JPSpotifyListTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *cover;

@end

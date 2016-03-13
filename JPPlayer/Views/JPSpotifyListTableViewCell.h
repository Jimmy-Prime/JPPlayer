//
//  JPSpotifyListTableViewCell.h
//  JPPlayer
//
//  Created by Prime on 1/29/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPSpotifyListTableViewCellIdentifier @"SpotifyListCell"
static const CGFloat JPSpotifyListTableCellHeight = 70.f;

@interface JPSpotifyListTableViewCell : UITableViewCell

@property (strong, nonatomic) SPTPartialTrack *track;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;
@property (strong, nonatomic) UIButton *optionButton;

@end

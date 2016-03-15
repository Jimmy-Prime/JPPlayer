//
//  JPSpotifyListTableViewCell.h
//  JPPlayer
//
//  Created by Prime on 1/29/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JPTrackCellIdentifier @"JPTrackCell"
static const CGFloat JPTrackCellHeight = 70.f;

@interface JPTrackCell : UITableViewCell

@property (strong, nonatomic) SPTPartialTrack *track;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;
@property (strong, nonatomic) UIButton *optionButton;

@end

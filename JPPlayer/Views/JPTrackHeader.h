//
//  JPTrackHeader.h
//  JPPlayer
//
//  Created by Prime on 3/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat JPTrackHeaderHeight = 80.f;

@interface JPTrackHeader : UIView

@property (strong, nonatomic) SPTPartialTrack *track;
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;

@end

//
//  JPSpotifyFeatureCollectionViewCell.m
//  JPPlayer
//
//  Created by Prime on 3/4/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyFeatureCollectionViewCell.h"

@implementation JPSpotifyFeatureCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {        
        _profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
        _profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_profileImageView];
        [_profileImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(_profileImageView.width);
        }];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor JPSelectedCellColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"Not Available";
        [self addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_profileImageView.bottom);
            make.bottom.left.right.equalTo(self);
        }];
    }
    
    return self;
}

@end

//
//  JPTrackHeader.m
//  JPPlayer
//
//  Created by Prime on 3/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPTrackHeader.h"

@implementation JPTrackHeader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor JPFakeHeaderColor];

        _coverImageView = [[UIImageView alloc] init];
        [self addSubview:_coverImageView];
        [_coverImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(8.f);
            make.bottom.equalTo(self).offset(-8.f);
            make.width.equalTo(_coverImageView.height);
        }];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        [self addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.left.equalTo(_coverImageView.right);
            make.height.equalTo(self).multipliedBy(0.6f);
        }];

        _auxilaryLabel = [[UILabel alloc] init];
        _auxilaryLabel.textAlignment = NSTextAlignmentCenter;
        _auxilaryLabel.textColor = [UIColor whiteColor];
        _auxilaryLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_auxilaryLabel];
        [_auxilaryLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(_coverImageView.right);
            make.height.equalTo(self).multipliedBy(0.4f);
        }];
    }

    return self;
}

- (void)setTrack:(SPTPartialTrack *)track {
    _track = track;

    [_coverImageView setImageWithURL:track.album.smallestCover.imageURL placeholderImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
    _titleLabel.text = track.name;
    SPTPartialArtist *artist0 = track.artists.firstObject;
    _auxilaryLabel.text = [NSString stringWithFormat:@"%@ - %@", artist0.name, track.album.name];
}

@end

//
//  JPSpotifyListTableViewCell.m
//  JPPlayer
//
//  Created by Prime on 1/29/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPTrackCell.h"
#import "JPPopupMenuView.h"

@implementation JPTrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor JPBackgroundColor];
        
        UIView *backgroundColorView = [[UIView alloc] init];
        backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
        self.selectedBackgroundView = backgroundColorView;
        
        _optionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _optionButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _optionButton.layer.borderWidth = 1.f;
        _optionButton.layer.cornerRadius = SmallButtonWidth / 2.f;
        [_optionButton setImage:[UIImage imageNamed:@"ic_more_horiz_white_48pt"] forState:UIControlStateNormal];
        _optionButton.contentMode = UIViewContentModeScaleAspectFit;
        _optionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _optionButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _optionButton.tintColor = [UIColor whiteColor];
        [_optionButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_optionButton];
        [_optionButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-8.f);
            make.width.height.equalTo(@(SmallButtonWidth));
        }];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(10.f);
            make.right.equalTo(_optionButton.left).offset(-10.f);
            make.height.equalTo(self).multipliedBy(0.5f);
        }];
        
        _auxilaryLabel = [[UILabel alloc] init];
        _auxilaryLabel.textColor = [UIColor grayColor];
        [self addSubview:_auxilaryLabel];
        [_auxilaryLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(30.f);
            make.right.equalTo(_optionButton.left).offset(-10.f);
            make.height.equalTo(self).multipliedBy(0.5f);
        }];
    }
    
    return self;
}

- (void)setTrack:(SPTPartialTrack *)track {
    _track = track;

    _titleLabel.text = track.name;
    SPTPartialArtist *artist0 = track.artists.firstObject;
    _auxilaryLabel.text = [NSString stringWithFormat:@"%@ - %@", artist0.name, track.album.name];
}

- (void)showMenu:(UIButton *)button {
    [[JPPopupMenuView defaultInstance] showMenuAtRefPoint:[self convertPoint:button.center toView:self.window] track:_track];
}

@end

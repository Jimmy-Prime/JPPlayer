//
//  JPSpotifyListTableViewCell.m
//  JPPlayer
//
//  Created by Prime on 1/29/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyListTableViewCell.h"

@implementation JPSpotifyListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor JPBackgroundColor];
        
        UIView *backgroundColorView = [[UIView alloc] init];
        backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
        self.selectedBackgroundView = backgroundColorView;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self);
            make.left.equalTo(self).offset(10.f);
            make.height.equalTo(self).multipliedBy(0.5f);
        }];
        
        _auxilaryLabel = [[UILabel alloc] init];
        _auxilaryLabel.textColor = [UIColor grayColor];
        [self addSubview:_auxilaryLabel];
        [_auxilaryLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self);
            make.left.equalTo(self).offset(20.f);
            make.height.equalTo(self).multipliedBy(0.5f);
        }];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

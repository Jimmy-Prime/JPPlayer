//
//  JPSpotifyListHeaderView.m
//  JPPlayer
//
//  Created by Prime on 2/28/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSpotifyListHeaderView.h"

@interface JPSpotifyListHeaderView()

@property (strong, nonatomic) UILabel *indicator;

@end

@implementation JPSpotifyListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor JPColor];
        
        _indicator = [[UILabel alloc] init];
        _indicator.textColor = [UIColor whiteColor];
        _indicator.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_indicator];
        [_indicator makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyListHeaderText:) name:@"SpotifyListHeaderText" object:nil];
    }
    
    return self;
}

- (void)spotifyListHeaderText:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    _indicator.text = [userInfo objectForKey:@"Text"];
}

@end

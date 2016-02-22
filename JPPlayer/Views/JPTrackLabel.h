//
//  JPTrackLabel.h
//  JPPlayer
//
//  Created by Prime on 1/11/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPTrackLabel : UILabel

typedef enum {
    JPTrackLabelTypeTrackOnly,
    JPTrackLabelTypeSingerOnly,
    JPTrackLabelTypeTrackAndSinger
} JPTrackLabelType;

@property JPTrackLabelType type;

- (instancetype)initWithType:(JPTrackLabelType)type;

- (void)setWithStrings:(NSArray <NSString *>*)strings;

@end

//
//  JPTrackLabel.m
//  JPPlayer
//
//  Created by Prime on 1/11/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPTrackLabel.h"

@implementation JPTrackLabel

- (instancetype)init {
    return [self initWithType:JPTrackLabelTypeTrackAndSinger];
}

-  (instancetype)initWithType:(JPTrackLabelType)type {
    self = [super init];
    if (self) {
        self.text = @"Album name - Track name";
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        
        _type = type;
    }
    
    return self;
}

- (void)setWithStrings:(NSArray<NSString *> *)strings {
    NSString *dataString = _type== JPTrackLabelTypeTrackAndSinger ?
        [NSString stringWithFormat:@"%@ - %@", [strings firstObject], [strings lastObject]] :
        [strings firstObject];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:dataString];
    if (_type != JPTrackLabelTypeSingerOnly) {
        [attrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(0, [[strings firstObject] length])];
    }
    [self setAttributedText:attrString];
}

- (void)setWithTrack:(NSString *)track Singer:(NSString *)singer {
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", track, singer]];
    [newString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, [track length])];
    [self setAttributedText:newString];
}

@end

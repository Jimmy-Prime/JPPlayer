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
    self = [super init];
    if (self) {
        self.text = @"Album name - Track name";
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

- (void)setWithTrack:(NSString *)track Singer:(NSString *)singer {
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", track, singer]];
    [newString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, [track length])];
    [self setAttributedText:newString];
}

@end

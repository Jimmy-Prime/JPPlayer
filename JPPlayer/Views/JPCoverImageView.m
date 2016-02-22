//
//  JPCoverImageView.m
//  JPPlayer
//
//  Created by Prime on 2/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPCoverImageView.h"

@implementation JPCoverImageView

- (void)setWith:(JPCoverImageView *)JPCover {
    _spotifyURI = JPCover.spotifyURI;
    self.image = JPCover.image;
}

@end

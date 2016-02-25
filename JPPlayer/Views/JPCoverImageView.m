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

- (void)setImage:(UIImage *)image {
    if (!_needsCrossFade) {
        [super setImage:image];
    }
    else {
        CATransition *fadeTransition = [CATransition animation];
        fadeTransition.duration = AnimationInterval;
        fadeTransition.type = kCATransitionFade;
        [super setImage:image];
        [self.layer addAnimation:fadeTransition forKey:nil];
    }
}

@end

//
//  SPT+image.m
//  JPPlayer
//
//  Created by Prime on 3/19/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "SPT+image.h"

@implementation SPTArtist (image)

- (SPTImage *)imageClosestToSize:(CGSize)size {
    SPTImage *target = self.images.lastObject;
    for (NSInteger i=self.images.count-1; i>=0; --i) {
        SPTImage *image = self.images[i];
        if (image.size.width < size.width || image.size.height < size.height) {
            break;
        }
        target = image;
    }

    return target;
}

@end

@implementation SPTPartialAlbum (image)

- (SPTImage *)imageClosestToSize:(CGSize)size {
    SPTImage *target = self.covers.lastObject;
    for (NSInteger i=self.covers.count-1; i>=0; --i) {
        SPTImage *image = self.covers[i];
        if (image.size.width < size.width || image.size.height < size.height) {
            break;
        }
        target = image;
    }

    return target;
}

@end

@implementation SPTPartialPlaylist (image)

- (SPTImage *)imageClosestToSize:(CGSize)size {
    SPTImage *target = self.images.lastObject;
    for (NSInteger i=self.images.count-1; i>=0; --i) {
        SPTImage *image = self.images[i];
        if (image.size.width < size.width || image.size.height < size.height) {
            break;
        }
        target = image;
    }

    return target;
}

@end

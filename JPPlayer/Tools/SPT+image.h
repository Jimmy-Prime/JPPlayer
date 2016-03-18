//
//  SPT+image.h
//  JPPlayer
//
//  Created by Prime on 3/19/16.
//  Copyright © 2016 Prime. All rights reserved.
//

@interface SPTArtist (image)
- (SPTImage *)imageClosestToSize:(CGSize)size;
@end

@interface SPTPartialAlbum (image)
- (SPTImage *)imageClosestToSize:(CGSize)size;
@end

@interface SPTPartialPlaylist (image)
- (SPTImage *)imageClosestToSize:(CGSize)size;
@end

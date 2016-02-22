//
//  JPCoverImageView.h
//  JPPlayer
//
//  Created by Prime on 2/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPCoverImageView : UIImageView

- (void)setWith:(JPCoverImageView *)JPCover;

@property (strong, nonatomic) NSURL *spotifyURI;

@end

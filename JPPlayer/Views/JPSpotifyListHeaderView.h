//
//  JPSpotifyListHeaderView.h
//  JPPlayer
//
//  Created by Prime on 2/28/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JPSpotifyListHeaderDelegate <NSObject>

- (void)refresh;

@end

@interface JPSpotifyListHeaderView : UIView

typedef enum {
    JPSpotifyHeaderNone,
    JPSpotifyHeaderCreating,
    JPSpotifyHeaderRenewing,
    JPSpotifyHeaderLogging,
    JPSpotifyHeaderRetrieving,
    JPSpotifyHeaderDone,
    JPSpotifyHeaderError
} JPSpotifyHeaderState;

@property (nonatomic) JPSpotifyHeaderState state;

@property (strong, nonatomic) id<JPSpotifyListHeaderDelegate> delegate;

@end

//
//  JPListTableViewController.h
//  JPPlayer
//
//  Created by Prime on 1/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPContainerTableViewController.h"

@interface JPListTableViewController : JPContainerTableViewController

typedef enum {
    SpotifyPlayList
} ListType;

@property ListType listType;
@property (strong, nonatomic) id information;

@end

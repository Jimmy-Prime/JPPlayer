//
//  JPTabViewController.h
//  JPPlayer
//
//  Created by Prime on 3/4/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPContainerViewController.h"

@interface JPTabViewController : UIViewController

typedef enum {
    Left,
    Right,
    Dock
} ContainerState;

@property (strong, nonatomic) NSMutableArray<JPContainerViewController *> *containerList;

- (void)addOneContainer:(JPContainerViewController *)container;

@end

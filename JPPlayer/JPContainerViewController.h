//
//  JPContainerViewController.h
//  JPPlayer
//
//  Created by Prime on 12/24/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface JPContainerViewController : UIViewController

@property (strong, nonatomic) MASConstraint *left;
@property (strong, nonatomic) MASConstraint *right;
@property (strong, nonatomic) MASConstraint *dock;
@property (strong, nonatomic) MASConstraint *transientSelf;
@property (strong, nonatomic) MASConstraint *transientOther;

@end

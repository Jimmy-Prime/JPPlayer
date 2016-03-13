//
//  JPPopupMenuView.h
//  JPPlayer
//
//  Created by Prime on 3/12/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPTabViewController.h"

@interface JPPopupMenuView : UIView

+ (instancetype)defaultInstance;
- (void)showMenuAtRefPoint:(CGPoint)point track:(SPTPartialTrack *)track;
- (void)dismissMenu;

@end

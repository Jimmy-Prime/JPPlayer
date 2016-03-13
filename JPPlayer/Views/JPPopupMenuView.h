//
//  JPPopupMenuView.h
//  JPPlayer
//
//  Created by Prime on 3/12/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPPopupMenuView : UIView

+ (instancetype)defaultInstance;
- (void)showMenuWithRefPoint:(CGPoint)point track:(SPTPartialTrack *)track;
- (void)dismissMenu;

@end

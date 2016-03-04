//
//  UIColor+JPColor.h
//  JPPlayer
//
//  Created by Prime on 2/23/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (JPColor)

+ (instancetype)JPColor;

+ (instancetype)colorWithR:(NSUInteger)R G:(NSUInteger)G B:(NSUInteger)B;

+ (instancetype)JPBackgroundColor;
+ (instancetype)JPSeparatorColor;
+ (instancetype)JPSelectedCellColor;
+ (instancetype)JPFakeHeaderColor;

@end

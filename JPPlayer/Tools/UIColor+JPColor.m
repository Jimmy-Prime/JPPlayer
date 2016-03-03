//
//  UIColor+JPColor.m
//  JPPlayer
//
//  Created by Prime on 2/23/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "UIColor+JPColor.h"

@implementation UIColor (JPColor)


+ (instancetype)colorWithR:(NSUInteger)R G:(NSUInteger)G B:(NSUInteger)B {
    return [UIColor colorWithRed:((CGFloat)R)/255.f green:((CGFloat)G)/255.f blue:((CGFloat)B)/255.f alpha:1.f];
}


+ (instancetype)JPColor {
//    return [UIColor colorWithR:255 G:40 B:0]; // FERRARI
//    return [UIColor colorWithR:207 G:0 B:15]; // MONZA
//    return [UIColor colorWithR:239 G:72 B:54]; // FLAMINGO
    NSData *themeColorData = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsThemeColorKey];
    if (themeColorData) {
        UIColor *themeColor = [NSKeyedUnarchiver unarchiveObjectWithData:themeColorData];
        return themeColor;
    }
    
    return [UIColor colorWithR:242 G:38 B:19]; // POMEGRANATE
}


+ (instancetype)JPBackgroundColor {
    return [UIColor colorWithRed:0.07f green:0.07f blue:0.08f alpha:1.f];
}

+ (instancetype)JPSeparatorColor {
    return [UIColor colorWithRed:0.17f green:0.18f blue:0.18f alpha:1.f];
}

+ (instancetype)JPSelectedCellColor {
    return [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.f];
}

+ (instancetype)JPFakeHeaderColor {
    return [UIColor colorWithRed:0.24f green:0.24f blue:0.24f alpha:1.f];
}

@end

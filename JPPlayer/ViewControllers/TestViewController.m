//
//  TestViewController.m
//  JPPlayer
//
//  Created by Prime on 12/11/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    srand48(arc4random());
    double x = drand48();
    
    [self.view setBackgroundColor:[UIColor colorWithHue:x saturation:0.7 brightness:0.7 alpha:1.f]];
}

@end

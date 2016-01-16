//
//  JPContainerViewController.m
//  JPPlayer
//
//  Created by Prime on 12/24/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPContainerViewController.h"

@interface JPContainerViewController ()

@end

@implementation JPContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    double x = drand48();
    [self.view setBackgroundColor:[UIColor colorWithHue:x saturation:0.7 brightness:0.7 alpha:1.f]];
    self.view.layer.cornerRadius = 20;
}

@end

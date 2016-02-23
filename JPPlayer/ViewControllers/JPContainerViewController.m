//
//  JPContainerViewController.m
//  JPPlayer
//
//  Created by Prime on 12/24/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JPContainerViewController.h"

@interface JPContainerViewController ()

@end

@implementation JPContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.view.backgroundColor = [UIColor JPBackgroundColor];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.view.layer.shadowOpacity = 0.5f;
    self.view.layer.shadowPath = shadowPath.CGPath;
    self.view.layer.shadowRadius = 10.f;
}

@end

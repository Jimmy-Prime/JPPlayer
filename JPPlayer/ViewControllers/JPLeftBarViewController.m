//
//  JPLeftBarViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPLeftBarViewController.h"

@interface JPLeftBarViewController ()

@end

@implementation JPLeftBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _leftBarView = [JPLeftBarView view];
    _leftBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [_leftBarView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_leftBarView];
    
    _rightContainerView = [[UIView alloc] init];
    _rightContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightContainerView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:_rightContainerView];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_leftBarView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_leftBarView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_rightContainerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_rightContainerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftBarView(100)][_rightContainerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_leftBarView, _rightContainerView)]];
    
    [self.view addConstraints:constraints];
}

@end

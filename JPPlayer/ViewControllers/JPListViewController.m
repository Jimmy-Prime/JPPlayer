//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPListViewController.h"
#import "JPListTableViewController.h"

@interface JPListViewController ()

@property (strong, nonatomic) JPListTableViewController *listViewController;
@property (strong, nonatomic) JPListTableViewController *testViewController;
@property (strong, nonatomic) NSArray *downViewConstraints;
@property (strong, nonatomic) NSArray *fullScreenConstraints;

@end

@implementation JPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _listViewController = [[JPListTableViewController alloc] init];
    [self addChildViewController:_listViewController];
    [self.view addSubview:_listViewController.view];
    
    _testViewController = [[JPListTableViewController alloc] init];
    [self addChildViewController:_testViewController];
    [self.view addSubview:_testViewController.view];
    
    UIView *leftView = _listViewController.view;
    UIView *rightView = _testViewController.view;
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(rightView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftView(==rightView)][rightView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftView, rightView, rightView)]];
    
    [self.view addConstraints:constraints];
}

@end

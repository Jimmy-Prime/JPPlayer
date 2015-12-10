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
    [self.rightContainerView addSubview:_listViewController.view];
    
    _testViewController = [[JPListTableViewController alloc] init];
    [self addChildViewController:_testViewController];
    [self.rightContainerView addSubview:_testViewController.view];
    
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
    
    [self.rightContainerView addConstraints:constraints];
    
    
    UIView *downView = [[UIView alloc] init];
    downView.translatesAutoresizingMaskIntoConstraints = NO;
    [downView setBackgroundColor:[UIColor blackColor]];
    downView.tag = 0;
    [self.view addSubview:downView];
    
    UIView *leftBarView = self.leftBarView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downViewTapped:)];
    [downView addGestureRecognizer:tap];
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBarView][downView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView, downView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[downView(50)]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(downView)]];
    
    [self.view addConstraints:constraints];
    
    _downViewConstraints = [NSArray arrayWithArray:constraints];
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[downView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(downView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[downView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(downView)]];
    
    _fullScreenConstraints = [NSArray arrayWithArray:constraints];
}


- (void)downViewTapped:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (view.tag == 0) {
            [self.view removeConstraints:_downViewConstraints];
            [self.view addConstraints:_fullScreenConstraints];
            [self.view layoutIfNeeded];
            view.tag = 1;
        }
        else {
            [self.view removeConstraints:_fullScreenConstraints];
            [self.view addConstraints:_downViewConstraints];
            [self.view layoutIfNeeded];
            view.tag = 0;
        }
    }];
}

@end

//
//  JPViewController.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPViewController.h"
#import "JPLeftBarView.h"
#import "JPPlayerView.h"
#import "JPListViewController.h"

@interface JPViewController()

@property (strong, nonatomic) UIView *rightContainerView;
@property (strong, nonatomic) NSMutableArray *childViewControllers;

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /****************************************/
    // JPLeftBarView and rightContainerView //
    /****************************************/
    JPLeftBarView *leftBarView = [[JPLeftBarView alloc] init];
    [leftBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [leftBarView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:leftBarView];
    
    _rightContainerView = [[UIView alloc] init];
    [_rightContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_rightContainerView];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[leftBarView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_rightContainerView]-70-|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_rightContainerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBarView(100)][_rightContainerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView, _rightContainerView)]];
    
    [self.view addConstraints:constraints];
    
    /********************************/
    // JPPlayerView and constraints //
    /********************************/
    JPPlayerView *playerView = [[JPPlayerView alloc] init];
    [playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [playerView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:playerView];
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[playerView(70)]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(playerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBarView][playerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView, playerView)]];
    
    [self.view addConstraints:constraints];
    playerView.normalConstraints = [NSArray arrayWithArray:constraints];
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(playerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(playerView)]];

    playerView.popupConstraints = [NSArray arrayWithArray:constraints];
    
    /*******************************/
    // Setup child viewcontrollers //
    /*******************************/
    _childViewControllers = [[NSMutableArray alloc] init];
    CGRect childFrame = CGRectMake(0, 0, _rightContainerView.frame.size.width, _rightContainerView.frame.size.height);
    
    JPListViewController *JPListVC = [[JPListViewController alloc] init];
    [_rightContainerView addSubview:JPListVC.view];
    [JPListVC.view setFrame:childFrame];
    [_childViewControllers addObject:JPListVC];
    
    [JPListVC didMoveToParentViewController:self];
}

@end

//
//  JPViewController.m
//  JPPlayer
//
//  Created by Prime on 12/10/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPViewController.h"
#import "Constants.h"
#import "JPLeftBarView.h"
#import "JPPlayerView.h"
#import "JPPopupPlayerView.h"
#import "JPListViewController.h"

#import "TestViewController.h"

@interface JPViewController()

@property (strong, nonatomic) UIView *rightContainerView;
@property (strong, nonatomic) NSMutableArray *childViewControllers;

@end

@implementation JPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*****************************************************/
    // JPLeftBarView & rightContainerView & JPPlayerView //
    /*****************************************************/
    JPLeftBarView *leftBarView = [[JPLeftBarView alloc] init];
    [leftBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [leftBarView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:leftBarView];
    
    _rightContainerView = [[UIView alloc] init];
    [_rightContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_rightContainerView];
    
    JPPlayerView *playerView = [[JPPlayerView alloc] init];
    [playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [playerView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:playerView];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[leftBarView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-20-[_rightContainerView][playerView(%lf)]|", PlayerViewHeight]
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_rightContainerView, playerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[leftBarView(%lf)][_rightContainerView]|", LeftBarWidth]
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView, _rightContainerView)]];
        
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBarView][playerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(leftBarView, playerView)]];
    
    [self.view addConstraints:constraints];
    
    /*********************/
    // JPPopupPlayerView //
    /*********************/
    JPPopupPlayerView *popupPlayerView = [[JPPopupPlayerView alloc] init];
    [popupPlayerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [popupPlayerView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:popupPlayerView];
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[popupPlayerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(popupPlayerView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[popupPlayerView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(popupPlayerView)]];
    
    popupPlayerView.constraints = [NSArray arrayWithArray:constraints];
    
    /*******************************/
    // Setup child viewcontrollers //
    /*******************************/
    _childViewControllers = [[NSMutableArray alloc] init];
    CGRect childFrame = CGRectMake(0, 0, _rightContainerView.frame.size.width, _rightContainerView.frame.size.height);
    
    // list tab
    CGFloat L = LeftBarWidth -16;
    UIView *listTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [listTab setBackgroundColor:[UIColor lightGrayColor]];
    listTab.layer.cornerRadius = 10;
    [leftBarView addTab:listTab];
    
    JPListViewController *JPListVC = [[JPListViewController alloc] init];
    [_rightContainerView addSubview:JPListVC.view];
    [JPListVC.view setFrame:childFrame];
    [_childViewControllers addObject:JPListVC];
    
    // test tab
    UIView *testTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [testTab setBackgroundColor:[UIColor grayColor]];
    testTab.layer.cornerRadius = 10;
    [leftBarView addTab:testTab];
    
    TestViewController *testVC1 = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC1.view];
    [testVC1.view setFrame:childFrame];
    [_childViewControllers addObject:testVC1];
    
    // test tab 2
    UIView *testTab2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, L, L)];
    [testTab2 setBackgroundColor:[UIColor darkGrayColor]];
    testTab2.layer.cornerRadius = 10;
    [leftBarView addTab:testTab2];
    
    TestViewController *testVC2 = [[TestViewController alloc] init];
    [_rightContainerView addSubview:testVC2.view];
    [testVC2.view setFrame:childFrame];
    [_childViewControllers addObject:testVC2];
    
    // default tab
    [JPListVC didMoveToParentViewController:self];
    [_rightContainerView bringSubviewToFront:JPListVC.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swithTab:) name:@"swithTab" object:nil];
}

- (void)swithTab:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSInteger index = [[userInfo objectForKey:@"tab"] integerValue];
    UIViewController *vc = [_childViewControllers objectAtIndex:index];
    [_rightContainerView bringSubviewToFront:vc.view];
}

@end

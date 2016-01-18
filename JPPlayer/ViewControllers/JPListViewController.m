//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPListViewController.h"
#import "Constants.h"
#import "JPContainerViewController.h"
#import "JPContainerTableViewController.h"
#import "JPListTableViewController.h"
#import "JPSingerTableViewController.h"

@interface JPListViewController ()

@property (strong, nonatomic) NSMutableArray *containerList;

enum ContainerState {
    Left,
    Right,
    Dock
};

@end

@implementation JPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.backgroundColor = [UIColor blackColor];
    resetButton.frame = CGRectMake(20, 20, 100, 100);
    resetButton.layer.cornerRadius = 20;
    [resetButton addTarget:self action:@selector(resetContainerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    _containerList = [[NSMutableArray alloc] init];
    
    [self addOneContainer];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:AnimationInterval animations:^{
        JPContainerViewController *last = [_containerList lastObject];
        last.view.tag = Right;
        [last.dock uninstall];
        [last.right install];
        [self.view layoutIfNeeded];
    }];
}

- (void)resetContainerButton:(UIButton *)button {
    for (JPContainerViewController *container in _containerList) {
        [container.view removeFromSuperview];
    }
    [_containerList removeAllObjects];
    [self addOneContainer];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:AnimationInterval animations:^{
        JPContainerViewController *last = [_containerList lastObject];
        last.view.tag = Right;
        [last.dock uninstall];
        [last.right install];
        [self.view layoutIfNeeded];
    }];
}

- (void)addOneContainer {
    JPContainerViewController *container;
    switch (arc4random() % 4) {
        case 0:
            container = [[JPContainerViewController alloc] init];
            break;
            
        case 1:
            container = [[JPContainerTableViewController alloc] init];
            break;
            
        case 2:
            container = [[JPListTableViewController alloc] init];
            break;
            
        case 3:
            container = [[JPSingerTableViewController alloc] init];
            break;
            
        default:
            break;
    }
    [self.view addSubview:container.view];
    
    JPContainerViewController *prev = [_containerList lastObject];
    [prev.view updateConstraints:^(MASConstraintMaker *make) {
        make.right.greaterThanOrEqualTo(container.view.left);
    }];
    
    container.view.tag = Dock;
    [container.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.left.greaterThanOrEqualTo(self.view);
        make.width.equalTo(@(ContainerWidth));
        container.left = make.left.equalTo(self.view).priorityLow();
        container.right = make.right.equalTo(self.view).priorityLow();
        container.dock = make.left.equalTo(self.view.right).priorityLow();
    }];
    
    [container.left uninstall];
    [container.right uninstall];
    
    container.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [container.view addGestureRecognizer:container.pan];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(30, 30, 50, 50);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 7.f;
    [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [container.view addSubview:button];
    
    [_containerList addObject:container];
}

- (void)tap:(UIButton *)button {
    UIView *view = button.superview;
    
    JPContainerViewController *container;
    container = [_containerList lastObject];
    if (container.view != view) {
        return;
    }
    
    [self addOneContainer];
    [self.view layoutIfNeeded];
    
    view.tag = Left;
    [UIView animateWithDuration:AnimationInterval animations:^{
        [container.right uninstall];
        [container.left install];
        
        JPContainerViewController *last = [_containerList lastObject];
        last.view.tag = Right;
        [last.dock uninstall];
        [last.right install];
        
        [self.view layoutIfNeeded];
    }];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    CGPoint move = [pan translationInView:view];
    NSInteger index;
    JPContainerViewController *container;
    for (index=0; index<[_containerList count]; ++index) {
        JPContainerViewController *vc = [_containerList objectAtIndex:index];
        if (vc.view == view) {
            container = vc;
            break;
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:AnimationInterval animations:^{
            [container.transientSelf uninstall];
            [container.transientOther uninstall];
            [container.left uninstall];
            [container.right uninstall];
            [container.dock uninstall];
            
            JPContainerViewController *left = index ? [_containerList objectAtIndex:index-1] : nil;
            JPContainerViewController *right = (index!=[_containerList count]-1) ? [_containerList objectAtIndex:index+1] : nil;
            
            if (view.center.x > self.view.frame.size.width) {
                // Dock
                view.tag = Dock;
                [container.dock install];
                
                if (left && left.view.tag != Right) {
                    left.view.tag = Right;
                    [left.left uninstall];
                    [left.right install];
                }
                if (right && right.view.tag != Dock) {
                    right.view.tag = Dock;
                    [right.right uninstall];
                    [right.dock install];
                }
            }
            else if (view.center.x > self.view.center.x || index == [_containerList count]-1) {
                // Right | (last & Left)
                view.tag = Right;
                [container.right install];
                
                if (left && left.view.tag != Left) {
                    left.view.tag = Left;
                    [left.right uninstall];
                    [left.left install];
                }
                if (right && right.view.tag != Dock) {
                    right.view.tag = Dock;
                    [right.right uninstall];
                    [right.dock install];
                }
            }
            else {
                // Left & !last
                view.tag = Left;
                [container.left install];
                
                if (left && left.view.tag != Left) {
                    left.view.tag = Left;
                    [left.right uninstall];
                    [left.left install];
                }
                if (right) {
                    right.view.tag = Right;
                    [right.dock uninstall];
                    [right.right install];
                }
            }
            
            [self.view layoutIfNeeded];
        }];
        
        return;
    }
    
    else if (pan.state == UIGestureRecognizerStateBegan) {
        [container.left uninstall];
        [container.right uninstall];
        [container.dock uninstall];
        
        if (view.tag == Left) {
            [view updateConstraints:^(MASConstraintMaker *make) {
                JPContainerViewController *next = [_containerList objectAtIndex:index+1];
                [next.right uninstall];
                container.transientOther = make.right.lessThanOrEqualTo(next.view.left).priorityHigh();
            }];
        }
    }
    
    [view updateConstraints:^(MASConstraintMaker *make) {
        if (view.tag == Right) {
            container.transientSelf = make.right.equalTo(self.view).offset(move.x).priorityHigh();
        }
        else if (view.tag == Left) {
            container.transientSelf = make.left.equalTo(self.view).offset(move.x).priorityHigh();
        }
    }];
}

@end

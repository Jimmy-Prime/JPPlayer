//
//  JPTabViewController.m
//  JPPlayer
//
//  Created by Prime on 3/4/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPTabViewController.h"

@interface JPTabViewController ()

@end

@implementation JPTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor JPBackgroundColor]];
    
    _containerList = [[NSMutableArray alloc] init];
}

#pragma mark - Other actions
- (void)addOneContainer:(JPContainerViewController *)container {
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
    
    [_containerList addObject:container];
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

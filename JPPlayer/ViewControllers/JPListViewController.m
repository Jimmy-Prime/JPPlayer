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

@interface JPListViewController ()

@property (strong, nonatomic) UIView *propView;
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
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _propView = [[UIView alloc] init];
    [_propView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:_propView];
    [_propView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.backgroundColor = [UIColor blackColor];
    addButton.frame = CGRectMake(20, 20, 100, 100);
    addButton.layer.cornerRadius = 20;
    [addButton addTarget:self action:@selector(addOneContainerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
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

- (void)addOneContainerButton:(UIButton *)button {
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
    JPContainerViewController *container = [[JPContainerViewController alloc] init];
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
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [container.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [container.view addGestureRecognizer:tap];
    
    [_containerList addObject:container];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    
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

//
//  JPContainerTableViewController.h
//  JPPlayer
//
//  Created by Prime on 1/18/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPContainerViewController.h"

@interface JPContainerTableViewController : JPContainerViewController

@property (strong, nonatomic) UIView *topView;
@property CGFloat topViewHeight;
@property (strong, nonatomic) UIView *fakeHeaderView;
@property (strong, nonatomic) UITableView *list;

@end

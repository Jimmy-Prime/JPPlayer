//
//  JPTabViewController.m
//  JPPlayer
//
//  Created by Prime on 3/1/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPTabTableViewController.h"

@implementation JPTabTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor JPBackgroundColor];
    _tableView.separatorColor = [UIColor JPSeparatorColor];
    [self.view addSubview:_tableView];
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.view);
        make.width.equalTo(@(ContainerWidth));
    }];
    
}

@end

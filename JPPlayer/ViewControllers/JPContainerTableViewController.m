//
//  JPContainerTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/18/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPContainerTableViewController.h"
#import "Constants.h"

@interface JPContainerTableViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@end

@implementation JPContainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _topViewHeight = ContainerWidth;
    
    _topView = [[UIView alloc] init];
    _topView.clipsToBounds = YES;
    [self.view addSubview:_topView];
    [_topView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(_topViewHeight));
    }];
    
    _list = [[UITableView alloc] init];
    _list.dataSource = self;
    _list.delegate = self;
    _list.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_list];
    [_list makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _fakeHeaderView = [[UIView alloc] init];
    _fakeHeaderView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_fakeHeaderView];
    [_fakeHeaderView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(_topView);
        make.height.equalTo(@(FakeHeaderHeight));
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *fakeHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, ContainerWidth)];
        [fakeHeader setBackgroundColor:[UIColor clearColor]];
        return fakeHeader;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return _topViewHeight;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 100 : 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _topViewHeight = ContainerWidth - scrollView.contentOffset.y;
    if (_topViewHeight < FakeHeaderHeight) {
        _topViewHeight = FakeHeaderHeight;
    }
    
    [_topView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(_topViewHeight));
    }];
}

@end

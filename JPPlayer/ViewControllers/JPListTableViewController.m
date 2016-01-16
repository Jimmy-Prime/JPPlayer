//
//  JPListTableViewController.m
//  JPPlayer
//
//  Created by Prime on 1/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <Masonry.h>
#import "JPListTableViewController.h"
#import "Constants.h"

@interface JPListTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property CGFloat minBlurImageHeight;
@property CGFloat blurImageHeight;
@property (strong, nonatomic) UIImageView *blurBackgroundImageView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) UIView *fakeHeaderView;
@property (strong, nonatomic) UITableView *list;

@end

@implementation JPListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _minBlurImageHeight = 100.f;
    _blurImageHeight = ContainerWidth;
    
    // init
    _list = [[UITableView alloc] init];
    [self.view addSubview:_list];
    
    _blurBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover.jpg"]];
    _blurBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_blurBackgroundImageView];
    
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [_blurBackgroundImageView addSubview:_blurEffectView];
    
    _fakeHeaderView = [[UIView alloc] init];
    [self.view addSubview:_fakeHeaderView];
    
    // layout
    [_blurBackgroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(_blurImageHeight));
    }];
    
    [_blurEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_blurBackgroundImageView);
    }];
    
    [_fakeHeaderView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(_blurBackgroundImageView);
        make.height.equalTo(@(_minBlurImageHeight));
        make.top.greaterThanOrEqualTo(_blurBackgroundImageView);
    }];
    
    [_list makeConstraints:^(MASConstraintMaker *make) {
        // make.top.equalTo(_blurBackgroundImageView.bottom);
        // make.bottom.left.right.equalTo(self.view);
        make.edges.equalTo(self.view);
    }];
    
    // other setup
    _fakeHeaderView.backgroundColor = [UIColor whiteColor];
    _fakeHeaderView.alpha = 0.1f;
    
    _list.dataSource = self;
    _list.delegate = self;
    _list.backgroundColor = [UIColor clearColor];
    /*
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [_blurBackgroundImageView addGestureRecognizer:pan];
    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [_list addGestureRecognizer:pan];*/
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
        return _blurImageHeight;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 100 : 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    // NSLog(@"PAN");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // NSLog(@"scrollViewDidScroll");
    
    _blurImageHeight = ContainerWidth - scrollView.contentOffset.y;
    if (_blurImageHeight < _minBlurImageHeight) {
        _blurImageHeight = _minBlurImageHeight;
    }

    [_blurBackgroundImageView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(_blurImageHeight));
    }];
}

@end

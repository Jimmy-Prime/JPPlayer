//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPListViewController.h"


@interface MyTableViewCell : UITableViewCell
@end

@implementation MyTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // overwrite style
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}
@end



@interface JPListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *listsTableView;
@property (strong, nonatomic) UITableView *contentsTableView;

@end

@implementation JPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect frame;
    _listsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _listsTableView.dataSource = self;
    _listsTableView.delegate = self;
    _listsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rightContainerView addSubview:_listsTableView];
    
    [_listsTableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"OAOCell"];
    
    _contentsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _contentsTableView.dataSource = self;
    _contentsTableView.delegate = self;
    _contentsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rightContainerView addSubview:_contentsTableView];
    
    [_contentsTableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"OAOCell"];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_listsTableView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_listsTableView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentsTableView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_contentsTableView)]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_listsTableView(==_contentsTableView)][_contentsTableView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_listsTableView, _contentsTableView, _contentsTableView)]];
    
    [self.view addConstraints:constraints];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 29;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"OAOCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"OAO Cell: %ld", (long)indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

@end

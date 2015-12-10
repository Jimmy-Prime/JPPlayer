//
//  JPListTableViewController.m
//  JPPlayer
//
//  Created by Prime on 12/9/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "JPListTableViewController.h"



@interface MyTableViewCell : UITableViewCell
@end

@implementation MyTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // overwrite style
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}
@end



@interface JPListTableViewController() <UIGestureRecognizerDelegate>

@property BOOL editing;
@property NSUInteger rows;

@end

@implementation JPListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editing = NO;
    _rows = 40;
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.bounces = NO;
    [self.tableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"OAOCell"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.5;
    longPress.delegate = self;
    [self.tableView addGestureRecognizer:longPress];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"OAOCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row) {
        cell.textLabel.text = @"Title";
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"OAO Cell: %ld", (long)indexPath.row];
    }
    else {
        cell.textLabel.text = @"New Playlist";
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _rows--;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    view.textLabel.text = @"Playlist";
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton sizeToFit];
    editButton.translatesAutoresizingMaskIntoConstraints = NO;
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:editButton];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[editButton]-30-|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(editButton)]];
    
    [constraints addObject:
     [NSLayoutConstraint constraintWithItem:editButton
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:view
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.f
                                   constant:0.f]];
    
    [view addConstraints:constraints];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row) {
        return;
    }
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Create new playlist"
                                        message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               NSLog(@"Create: %@", [alert.textFields objectAtIndex:0].text);
                           }];
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction *action) {
                               NSLog(@"Cancel");
                           }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.font = [UIFont systemFontOfSize:32];
    }];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Other
- (void)edit:(UIButton *)button {
    if (_editing) {
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [self.tableView setEditing:NO animated:YES];
    }
    else {
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }
    
    _editing = !_editing;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != nil && indexPath.row && longPress.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *title = cell.detailTextLabel.text;
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Rename \"%@\"", title]
                                            message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction =
        [UIAlertAction actionWithTitle:@"Rename"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   NSLog(@"Rename to %@", [alert.textFields objectAtIndex:0].text);
                               }];
        UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) {
                                   NSLog(@"Cancel");
                               }];
        
        [alert addAction:confirmAction];
        [alert addAction:cancelAction];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.font = [UIFont systemFontOfSize:32];
        }];
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end

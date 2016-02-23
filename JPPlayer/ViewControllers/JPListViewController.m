//
//  JPListViewController.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPListViewController.h"
#import "JPContainerViewController.h"
#import "JPContainerTableViewController.h"
#import "JPListTableViewController.h"
#import "JPSingerTableViewController.h"
#import "JPSpotifyListViewCell.h"

@interface JPListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *listsTableView;
@property (strong, nonatomic) NSMutableArray<JPContainerViewController *> *containerList;
@property (strong, nonatomic) SPTPlaylistList *SpotifyLists;

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
    
    [self.view setBackgroundColor:[UIColor JPBackgroundColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifySession:) name:@"SpotifySession" object:nil];

    SPTSession *session = [[SPTAuth defaultInstance] session];
    [self checkSession:session];
    
    _listsTableView = [[UITableView alloc] init];
    _listsTableView.dataSource = self;
    _listsTableView.delegate = self;
    _listsTableView.backgroundColor = [UIColor JPBackgroundColor];
    _listsTableView.separatorColor = [UIColor JPSeparatorColor];
    [self.view addSubview:_listsTableView];
    [_listsTableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.view);
        make.width.equalTo(@(ContainerWidth));
    }];
    
    _containerList = [[NSMutableArray alloc] init];
}

- (void)checkSession:(SPTSession *)session {
    if (!session) {
        NSLog(@"No session");
        return;
    }
    
    if ([session isValid]) {
        [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, SPTPlaylistList *lists) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            
            _SpotifyLists = lists;
            [_listsTableView reloadData];
        }];
    }
    else {
        // TODO: refresh token
        NSLog(@"Invalid session");
    }
}

- (void)spotifySession:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    SPTSession *session = [userInfo objectForKey:@"SpotifySession"];
    [self checkSession:session];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && _SpotifyLists != nil) {
        return _SpotifyLists.tracksForPlayback.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // spotify section
        JPSpotifyListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JPSpotifyListViewCellIdentifier];
        if (cell == nil) {
            cell = [[JPSpotifyListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPSpotifyListViewCellIdentifier];
        }
        
        SPTPartialPlaylist *partialPlayList = [[_SpotifyLists tracksForPlayback] objectAtIndex:indexPath.row];
        UIImage *placeHolder = [UIImage imageNamed:@"PlaceHolder.jpg"];
        [cell.profileImageView setImageWithURL:partialPlayList.smallestImage.imageURL placeholderImage:placeHolder];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", partialPlayList.name];
        cell.auxilaryLabel.text = [@(partialPlayList.trackCount) stringValue];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) { // spotify header
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, 120)];
        header.backgroundColor = [UIColor JPColor];
        return header;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 120.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return JPSpotifyListCellHeight;
    }
    
    return 0.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Spotify section
        for (JPContainerViewController *container in _containerList) {
            [container.view removeFromSuperview];
        }
        [_containerList removeAllObjects];
        
        JPListTableViewController *newSpotifyListVC = [[JPListTableViewController alloc] init];
        newSpotifyListVC.listType = SpotifyPlayList;
        SPTPartialPlaylist *partialPlayList = [[_SpotifyLists tracksForPlayback] objectAtIndex:indexPath.row];
        newSpotifyListVC.information = partialPlayList;
        
        [self addOneContainer:newSpotifyListVC];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:AnimationInterval animations:^{
            JPContainerViewController *last = [_containerList lastObject];
            last.view.tag = Right;
            [last.dock uninstall];
            [last.right install];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - Other actions
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

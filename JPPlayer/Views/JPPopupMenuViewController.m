//
//  JPPopupMenuView.m
//  JPPlayer
//
//  Created by Prime on 3/12/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "JPPopupMenuViewController.h"
#import "JPPopupMenuTableViewController.h"
#import "JPAlbumTableViewController.h"
#import "JPArtistCollectionViewController.h"
#import "JPSpotifySession.h"

#define HeaderHeight 80.f
#define CellHeight 60.f

@interface JPPopupMenuViewController() <UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *backgroundContainerView;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) UIView *headerContainerView;
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *auxilaryLabel;

@property (strong, nonatomic) SPTPartialTrack *track;

@property (strong, nonatomic) UIViewController *rootVC;
@property (strong, nonatomic) UITableView *actionTableView;
@property (strong, nonatomic) NSArray *menuCaptions;
@property (strong, nonatomic) NSArray *menuImageNames;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) JPPopupMenuTableViewController *playlistTable;

@end

@implementation JPPopupMenuViewController

static id defaultInstance;

+ (instancetype)defaultInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /*******************************/
        // Setup background touch view //
        /*******************************/
        UIWindow *window = [UIApplication sharedApplication].delegate.window;

        _backgroundContainerView = [[UIView alloc] init];
        _backgroundContainerView.hidden = YES;
        [window addSubview:_backgroundContainerView];
        [_backgroundContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];

        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [_backgroundView addGestureRecognizer:tap];
        [_backgroundContainerView addSubview:_backgroundView];
        [_backgroundView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_backgroundContainerView);
        }];

        self.delegate = self;
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];

        self.view.backgroundColor = [UIColor JPBackgroundColor];
        self.view.layer.cornerRadius = 10.f;
        self.view.clipsToBounds = YES;
        [self setNavigationBarHidden:YES];
        [_backgroundContainerView addSubview:self.view];
        [self.view makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(PopupMenuWidth));
            make.height.equalTo(@(HeaderHeight));
            make.right.equalTo(_backgroundContainerView).offset(-(8.f + SmallButtonWidth + 8.f));
            make.centerY.equalTo(_backgroundContainerView).priorityLow();
            make.top.greaterThanOrEqualTo(_backgroundContainerView.top).offset(20.f);
            make.bottom.lessThanOrEqualTo(_backgroundContainerView.bottom).offset(-20.f);
        }];

        /******************************/
        // Setup root view controller //
        /******************************/
        _rootVC = [[UIViewController alloc] init];
        _rootVC.view.backgroundColor = [UIColor JPBackgroundColor];
        [self setViewControllers:@[_rootVC]];

        _rootVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        _rootVC.navigationController.navigationBar.tintColor = [UIColor JPColor];

        _menuCaptions = @[@"Add",
                          @"Add to Playlist",
                          @"Go to Album",
                          @"Go to Artist",
                          @"Share"];
        _menuImageNames = @[@"ic_add_circle_white_48pt",
                            @"ic_playlist_add_white_48pt",
                            @"ic_album_white_48pt",
                            @"ic_headset_white_48pt",
                            @"ic_share_white_48pt"];

        _actionTableView = [[UITableView alloc] init];
        _actionTableView.dataSource = self;
        _actionTableView.delegate = self;
        _actionTableView.backgroundColor = [UIColor JPBackgroundColor];
        _actionTableView.separatorColor = [UIColor JPSeparatorColor];
        [_rootVC.view addSubview:_actionTableView];

        _headerContainerView = [[UIView alloc] init];
        _headerContainerView.backgroundColor = [UIColor JPFakeHeaderColor];
        [_rootVC.view addSubview:_headerContainerView];
        [_headerContainerView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_rootVC.view);
            make.height.equalTo(@(HeaderHeight));
        }];

        _coverImageView = [[UIImageView alloc] init];
        [_headerContainerView addSubview:_coverImageView];
        [_coverImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(_headerContainerView).offset(8.f);
            make.bottom.equalTo(_headerContainerView).offset(-8.f);
            make.width.equalTo(_coverImageView.height);
        }];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        [_headerContainerView addSubview:_titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_headerContainerView);
            make.left.equalTo(_coverImageView.right);
            make.height.equalTo(_headerContainerView).multipliedBy(0.6f);
        }];

        _auxilaryLabel = [[UILabel alloc] init];
        _auxilaryLabel.textAlignment = NSTextAlignmentCenter;
        _auxilaryLabel.textColor = [UIColor whiteColor];
        _auxilaryLabel.font = [UIFont systemFontOfSize:12];
        [_headerContainerView addSubview:_auxilaryLabel];
        [_auxilaryLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(_headerContainerView);
            make.left.equalTo(_coverImageView.right);
            make.height.equalTo(_headerContainerView).multipliedBy(0.4f);
        }];

        _playlistTable = [[JPPopupMenuTableViewController alloc] init];
    }

    return self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == navigationController.viewControllers.firstObject) {
        [navigationController setNavigationBarHidden:YES];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self dismissMenu];
}

- (void)showMenuAtRefPoint:(CGPoint)point track:(SPTPartialTrack *)track {
    _track = track;
    _playlistTable.track = track;

    CGFloat y = point.y - [UIScreen mainScreen].bounds.size.height / 2.f;

    [self.view updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(HeaderHeight));
        make.centerY.equalTo(_backgroundContainerView.centerY).offset(y).priorityLow();
    }];

    [_actionTableView remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_actionTableView.superview);
    }];
    [_backgroundContainerView layoutIfNeeded];

    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(HeaderHeight + _menuCaptions.count * CellHeight));
        }];

        [_actionTableView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerContainerView.bottom);
            make.bottom.left.right.equalTo(_actionTableView.superview);
        }];
        [_backgroundContainerView layoutIfNeeded];
    }];

    [_coverImageView setImageWithURL:track.album.smallestCover.imageURL placeholderImage:[UIImage imageNamed:@"PlaceHolder.jpg"]];
    _titleLabel.text = track.name;
    SPTPartialArtist *artist0 = track.artists.firstObject;
    _auxilaryLabel.text = [NSString stringWithFormat:@"%@ - %@", artist0.name, track.album.name];

    _backgroundContainerView.hidden = NO;
}

- (void)dismissMenu {
    [UIView animateWithDuration:AnimationInterval animations:^{
        [self.view updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(HeaderHeight));
        }];

        [_actionTableView remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_actionTableView.superview);
        }];
        [_backgroundContainerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        _backgroundContainerView.hidden = YES;
        [_actionTableView deselectRowAtIndexPath:_selectedIndexPath animated:NO];

        [self popToRootViewControllerAnimated:NO];
        [self setNavigationBarHidden:YES];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuCaptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
    }

    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
    cell.selectedBackgroundView = backgroundColorView;

    cell.backgroundColor = [UIColor JPBackgroundColor];

    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = [UIImage imageNamed:_menuImageNames[indexPath.row]];

    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.text = _menuCaptions[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;

    switch (indexPath.row) {
        case 0: { // Add
            NSString *accessToken = [JPSpotifySession defaultInstance].session.accessToken;
            #warning shorthand method not working
            NSURLRequest *req = [SPTYourMusic createRequestForCheckingIfSavedTracksContains:@[_track] forUserWithAccessToken:accessToken error:nil];
            [[SPTRequest sharedHandler] performRequest:req callback:^(NSError *error, NSURLResponse *response, NSData *data) {
                if (error) {
                    NSLog(@"error: %@", error);
                    return;
                }

                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([result isEqualToString:@"[ false ]"]) {
                    [SPTYourMusic saveTracks:@[_track] forUserWithAccessToken:accessToken callback:nil];

                    NSString *message = [NSString stringWithFormat:@"%@ is saved", _track.name];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Succeeded" message:message preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:defaultAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];

            [self dismissMenu];
            break;
    }

        case 1: { // Add to Playlist
            [self pushViewController:_playlistTable animated:YES];
            [self setNavigationBarHidden:NO];
            break;
        }

        case 2: { // Go to Album
            JPAlbumTableViewController *newAlbumVC = [[JPAlbumTableViewController alloc] init];
            newAlbumVC.information = _track.album;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newAlbumVC}];

            [self dismissMenu];
            break;
        }

        case 3: { // Go to Artist
            JPArtistCollectionViewController *newArtistVC = [[JPArtistCollectionViewController alloc] init];
            newArtistVC.information = _track.artists.firstObject;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newContainer" object:nil userInfo:@{@"container" : newArtistVC}];

            [self dismissMenu];
            break;
        }

        case 4: // Share
            break;

        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

@end

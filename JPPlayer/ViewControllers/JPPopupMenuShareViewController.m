//
//  JPPopupMenuShareViewController.m
//  JPPlayer
//
//  Created by Prime on 3/22/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import <FBSDKShareKit/FBSDKShareKit.h>
#import "JPPopupMenuShareViewController.h"
#import "JPPopupMenuViewController.h"

@interface JPPopupMenuShareViewController ()

@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *imageNames;

@end

@implementation JPPopupMenuShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _titles = @[@"Share on Facebook",
                @"Copy Spotify URI",
                @"Copy Link"];

    _imageNames = @[@"facebook_icon",
                    @"ic_content_copy_white_48pt",
                    @"ic_content_copy_white_48pt"];

    self.tableView.backgroundColor = [UIColor JPBackgroundColor];
    self.tableView.separatorColor = [UIColor JPSeparatorColor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];

        UIView *backgroundColorView = [[UIView alloc] init];
        backgroundColorView.backgroundColor = [UIColor JPSelectedCellColor];
        cell.selectedBackgroundView = backgroundColorView;

        cell.backgroundColor = [UIColor JPBackgroundColor];

        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:20];
    }

    cell.imageView.image = [UIImage imageNamed:_imageNames[indexPath.row]];

    cell.textLabel.text = _titles[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = _track.sharingURL;
            [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
            break;
        }

        case 1:
            [UIPasteboard generalPasteboard].string = _track.playableUri.absoluteString;
            break;

        case 2:
            [UIPasteboard generalPasteboard].string = _track.sharingURL.absoluteString;
            break;

        default:
            break;
    }

    [[JPPopupMenuViewController defaultInstance] dismissMenu];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PopupMenuCellHeight;
}

@end

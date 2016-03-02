//
//  JPSettingColorViewController.m
//  JPPlayer
//
//  Created by Prime on 3/2/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSettingsColorViewController.h"

@interface JPSettingsColorViewController ()

@property (strong, nonatomic) UIView *previewView;

@end

@implementation JPSettingsColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // cancel button, preview player, OK button
    UIView *controlContainer = [[UIView alloc] init];
    controlContainer.backgroundColor = [UIColor JPBackgroundColor];
    [self.view addSubview:controlContainer];
    [controlContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(PlayerViewHeight));
    }];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setImage:[UIImage imageNamed:@"ic_cancel_white_48pt"] forState:UIControlStateNormal];
    cancelButton.contentMode = UIViewContentModeScaleAspectFit;
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    cancelButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    cancelButton.tintColor = [UIColor JPColor];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [controlContainer addSubview:cancelButton];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(controlContainer).offset(8.f);
        make.bottom.equalTo(controlContainer).offset(-8.f);
        make.width.equalTo(cancelButton.height);
    }];
    
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkButton setImage:[UIImage imageNamed:@"ic_check_circle_white_48pt"] forState:UIControlStateNormal];
    checkButton.contentMode = UIViewContentModeScaleAspectFit;
    checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    checkButton.tintColor = [UIColor JPColor];
    [checkButton addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    [controlContainer addSubview:checkButton];
    [checkButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlContainer).offset(8.f);
        make.bottom.right.equalTo(controlContainer).offset(-8.f);
        make.width.equalTo(checkButton.height);
    }];
    
    _previewView = [[UIView alloc] init];
    _previewView.layer.cornerRadius = 8.f;
    _previewView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _previewView.layer.borderWidth = 2.f;
    _previewView.backgroundColor = [UIColor JPColor];
    [controlContainer addSubview:_previewView];
    [_previewView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(controlContainer);
        make.width.equalTo(@(ContainerWidth - 2.f*(PlayerViewHeight + 16.f)));
        make.height.equalTo(@(PlayerViewHeight - 16.f));
    }];
    
    UILabel *previewLabel = [[UILabel alloc] init];
    previewLabel.font = [UIFont systemFontOfSize:11];
    previewLabel.textAlignment = NSTextAlignmentCenter;
    previewLabel.textColor = [UIColor whiteColor];
    previewLabel.text = @"Selected Color";
    [_previewView addSubview:previewLabel];
    [previewLabel makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_previewView);
    }];
        
    // scroll view
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlContainer.bottom);
        make.bottom.left.right.equalTo(self.view);
    }];
    
        // pre load colors
    UIView *colorSetContainer = [[UIView alloc] init];
    colorSetContainer.backgroundColor = [UIColor JPColor];
    [scrollView addSubview:colorSetContainer];
    [colorSetContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(scrollView);
        make.width.equalTo(@(ContainerWidth));
        make.height.equalTo(@(600.f));
    }];
    
        // color palette
    UIImageView *colorPalette = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Color Palette.png"]];
    colorPalette.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:colorPalette];
    [colorPalette makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorSetContainer.bottom).offset(20.f);
        make.centerX.equalTo(scrollView);
        make.width.height.equalTo(@(ContainerWidth - 40.f));
    }];
    
        // bar
    UIView *brightnessBar = [[UIView alloc] init];
    brightnessBar.backgroundColor = [UIColor JPColor];
    [scrollView addSubview:brightnessBar];
    [brightnessBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorPalette.bottom).offset(20.f);
        make.bottom.equalTo(scrollView).offset(-25.f);
        make.centerX.equalTo(scrollView);
        make.width.equalTo(colorPalette);
        make.height.equalTo(@(40.f));
    }];
    
    UIPanGestureRecognizer *barPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(barPan:)];
    [brightnessBar addGestureRecognizer:barPan];

    UIView *slider = [[UIView alloc] init];
    slider.layer.cornerRadius = 10.f;
    slider.layer.borderColor = [[UIColor whiteColor] CGColor];
    slider.layer.borderWidth = 2.f;
    [brightnessBar addSubview:slider];
    [slider makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(brightnessBar);
        make.centerX.equalTo(brightnessBar.left);
        make.width.equalTo(@(2.f * slider.layer.cornerRadius));
        make.height.equalTo(@(50.f));
    }];
}

- (void)cancel:(UIButton *)button {
    NSLog(@"cancel");
}

- (void)check:(UIButton *)button {
    NSLog(@"check");
}

- (void)barPan:(UIPanGestureRecognizer *)pan {
    NSLog(@"%@", NSStringFromCGPoint([pan locationInView:pan.view]));
    
    UIView *slider = pan.view.subviews.firstObject;
    
}

@end

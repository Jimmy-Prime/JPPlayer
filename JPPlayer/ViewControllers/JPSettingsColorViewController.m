//
//  JPSettingColorViewController.m
//  JPPlayer
//
//  Created by Prime on 3/2/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSettingsColorViewController.h"
#import "JPGradientView.h"

@interface JPSettingsColorViewController ()

@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) UIView *controlContainer;
@property (strong, nonatomic) JPGradientView *brightnessBar;

@end

@implementation JPSettingsColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selectedColor = [UIColor JPColor];
    
    // cancel button, preview player, OK button
    _controlContainer = [[UIView alloc] init];
    _controlContainer.backgroundColor = [UIColor JPBackgroundColor];
    [self.view addSubview:_controlContainer];
    [_controlContainer makeConstraints:^(MASConstraintMaker *make) {
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
    [_controlContainer addSubview:cancelButton];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_controlContainer).offset(8.f);
        make.bottom.equalTo(_controlContainer).offset(-8.f);
        make.width.equalTo(cancelButton.height);
    }];
    
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkButton setImage:[UIImage imageNamed:@"ic_check_circle_white_48pt"] forState:UIControlStateNormal];
    checkButton.contentMode = UIViewContentModeScaleAspectFit;
    checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    checkButton.tintColor = [UIColor JPColor];
    [checkButton addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer addSubview:checkButton];
    [checkButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_controlContainer).offset(8.f);
        make.bottom.right.equalTo(_controlContainer).offset(-8.f);
        make.width.equalTo(checkButton.height);
    }];
    
    UIView *previewView = [[UIView alloc] init];
    previewView.layer.cornerRadius = 8.f;
    previewView.layer.borderColor = [[UIColor whiteColor] CGColor];
    previewView.layer.borderWidth = 2.f;
    previewView.backgroundColor = [UIColor JPColor];
    [_controlContainer addSubview:previewView];
    [previewView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_controlContainer);
        make.width.equalTo(@(ContainerWidth - 2.f*(PlayerViewHeight + 16.f)));
        make.height.equalTo(@(PlayerViewHeight - 16.f));
    }];
    
    UILabel *previewLabel = [[UILabel alloc] init];
    previewLabel.font = [UIFont systemFontOfSize:11];
    previewLabel.textAlignment = NSTextAlignmentCenter;
    previewLabel.textColor = [UIColor whiteColor];
    previewLabel.text = @"Selected Color";
    [previewView addSubview:previewLabel];
    [previewLabel makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(previewView);
    }];
        
    // scroll view
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_controlContainer.bottom);
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
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
        // color palette
    UIImageView *colorPalette = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Color Palette.png"]];
    colorPalette.contentMode = UIViewContentModeScaleAspectFit;
    colorPalette.userInteractionEnabled = YES;
    [scrollView addSubview:colorPalette];
    [colorPalette makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorSetContainer.bottom).offset(20.f);
        make.centerX.equalTo(scrollView);
        make.width.height.equalTo(@(ContainerWidth - 40.f));
    }];
    
    UIPanGestureRecognizer *palettePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(palettePan:)];
    [colorPalette addGestureRecognizer:palettePan];
    
    UIView *pick = [[UIView alloc] init];
    pick.layer.cornerRadius = 15.f;
    pick.layer.borderColor = [[UIColor whiteColor] CGColor];
    pick.layer.borderWidth = 2.f;
    [colorPalette addSubview:pick];
    [pick makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(colorPalette.left).offset(hue * (ContainerWidth - 40.f));
        make.centerY.equalTo(colorPalette.top).offset((1.f - saturation) * (ContainerWidth - 40.f));
        make.width.height.equalTo(@(2.f * pick.layer.cornerRadius));
    }];
    
        // bar
    _brightnessBar = [[JPGradientView alloc] init];
    _brightnessBar.color = _selectedColor;
    [scrollView addSubview:_brightnessBar];
    [_brightnessBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorPalette.bottom).offset(20.f);
        make.bottom.equalTo(scrollView).offset(-25.f);
        make.centerX.equalTo(scrollView);
        make.width.equalTo(colorPalette);
        make.height.equalTo(@(40.f));
    }];
    
    UIPanGestureRecognizer *barPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(barPan:)];
    [_brightnessBar addGestureRecognizer:barPan];

    UIView *slider = [[UIView alloc] init];
    slider.layer.cornerRadius = 10.f;
    slider.layer.borderColor = [[UIColor whiteColor] CGColor];
    slider.layer.borderWidth = 2.f;
    [_brightnessBar addSubview:slider];
    [slider makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_brightnessBar.left).offset((1.f - brightness) * (ContainerWidth - 40.f));
        make.centerY.equalTo(_brightnessBar);
        make.width.equalTo(@(2.f * slider.layer.cornerRadius));
        make.height.equalTo(@(50.f));
    }];
}

- (void)cancel:(UIButton *)button {
    NSLog(@"cancel");
}

- (void)check:(UIButton *)button {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedColor = [NSKeyedArchiver archivedDataWithRootObject:_selectedColor];
    [userDefaults setObject:encodedColor forKey:UserDefaultsThemeColorKey];
    [userDefaults synchronize];
}

- (void)palettePan:(UIPanGestureRecognizer *)pan {
    UIView *palette = pan.view;
    UIView *pick = palette.subviews.firstObject;
    
    CGFloat offsetX = MAX([pan locationInView:palette].x, 0.f);
    offsetX = MIN(offsetX, CGRectGetWidth(palette.frame));
    CGFloat offsetY = MAX([pan locationInView:palette].y, 0.f);
    offsetY = MIN(offsetY, CGRectGetHeight(palette.frame));
    
    [pick updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(palette.left).offset(offsetX);
        make.centerY.equalTo(palette.top).offset(offsetY);
    }];
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newHue = offsetX / CGRectGetWidth(palette.frame);
    CGFloat newSaturation = 1.f - offsetY / CGRectGetHeight(palette.frame);
    _selectedColor = [UIColor colorWithHue:newHue saturation:newSaturation brightness:brightness alpha:alpha];
    for (UIView *view in _controlContainer.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.tintColor = _selectedColor;
        }
        else {
            view.backgroundColor = _selectedColor;
        }
    }
    
    _brightnessBar.color = [UIColor colorWithHue:newHue saturation:newSaturation brightness:1.f alpha:1.f];
}

- (void)barPan:(UIPanGestureRecognizer *)pan {
    UIView *slider = pan.view.subviews.firstObject;
    
    CGFloat offsetX = MAX([pan locationInView:pan.view].x, 0.f);
    offsetX = MIN(offsetX, CGRectGetWidth(pan.view.frame));
    
    [slider updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(pan.view.left).offset(offsetX);
    }];
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newBrightness = 1.f - offsetX / CGRectGetWidth(pan.view.frame);
    _selectedColor = [UIColor colorWithHue:hue saturation:saturation brightness:newBrightness alpha:alpha];
    for (UIView *view in _controlContainer.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.tintColor = _selectedColor;
        }
        else {
            view.backgroundColor = _selectedColor;
        }
    }
}

@end

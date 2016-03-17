//
//  JPSettingColorViewController.m
//  JPPlayer
//
//  Created by Prime on 3/2/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPSettingsColorViewController.h"
#import "JPGradientView.h"

@interface JPSettingsColorViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) UIView *controlContainer;
@property (strong, nonatomic) JPGradientView *brightnessBar;

@property (strong, nonatomic) UIView *pick;
@property (strong, nonatomic) UIView *slider;

@property (nonatomic) CGSize cellSize;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *colorNames;

@end

@implementation JPSettingsColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selectedColor = [UIColor JPColor];
    
    // cancel button, reset to default button, preview view, OK button
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
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setImage:[UIImage imageNamed:@"ic_refresh_white_48pt"] forState:UIControlStateNormal];
    resetButton.contentMode = UIViewContentModeScaleAspectFit;
    resetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    resetButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    resetButton.tintColor = [UIColor JPColor];
    [resetButton addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [_controlContainer addSubview:resetButton];
    [resetButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_controlContainer).offset(8.f);
        make.bottom.equalTo(_controlContainer).offset(-8.f);
        make.left.equalTo(cancelButton.right).offset(8.f);
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
        make.top.equalTo(_controlContainer).offset(8.f);
        make.bottom.equalTo(_controlContainer).offset(-8.f);
        make.left.equalTo(resetButton.right).offset(8.f);
        make.right.equalTo(checkButton.left).offset(-8.f);
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
    _cellSize = (CGSize){(ContainerWidth - 80.f) / 3.f, 170.f};
    _colors = @[[UIColor colorWithR:242 G:38 B:19],
                [UIColor colorWithR:30 G:215 B:97],
                [UIColor colorWithR:255 G:40 B:0],
                [UIColor colorWithR:207 G:0 B:15],
                [UIColor colorWithR:239 G:72 B:54]];
    
    _colorNames = @[@"JP Red",
                    @"Spotify Green",
                    @"Ferrari",
                    @"Monza",
                    @"Flamingo"];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = _cellSize;
    
    UICollectionView *colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    colorCollectionView.backgroundColor = [UIColor clearColor];
    [colorCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ColorCell"];
    colorCollectionView.dataSource = self;
    colorCollectionView.delegate = self;
    [scrollView addSubview:colorCollectionView];
    [colorCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(scrollView).offset(20.f);
        make.right.equalTo(scrollView).offset(-20.f);
        make.width.equalTo(@(ContainerWidth - 40.f));
        NSUInteger rowCount = ceil((double)_colors.count / 3.f);
        make.height.equalTo(@(10.f + (CGFloat)rowCount * _cellSize.height + (CGFloat)(rowCount-1) * 10.f));
    }];
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
        // color palette
    UIImageView *colorPalette = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Color Palette.png"]];
    colorPalette.contentMode = UIViewContentModeScaleAspectFit;
    colorPalette.userInteractionEnabled = YES;
    [scrollView addSubview:colorPalette];
    [colorPalette makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorCollectionView.bottom).offset(20.f);
        make.centerX.equalTo(scrollView);
        make.width.height.equalTo(@(ContainerWidth - 40.f));
    }];
    
    UIPanGestureRecognizer *palettePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(palettePan:)];
    [colorPalette addGestureRecognizer:palettePan];
    
    _pick = [[UIView alloc] init];
    _pick.layer.cornerRadius = 15.f;
    _pick.layer.borderColor = [[UIColor whiteColor] CGColor];
    _pick.layer.borderWidth = 2.f;
    [colorPalette addSubview:_pick];
    [_pick makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(colorPalette.left).offset(hue * (ContainerWidth - 40.f));
        make.centerY.equalTo(colorPalette.top).offset((1.f - saturation) * (ContainerWidth - 40.f));
        make.width.height.equalTo(@(2.f * _pick.layer.cornerRadius));
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

    _slider = [[UIView alloc] init];
    _slider.layer.cornerRadius = 10.f;
    _slider.layer.borderColor = [[UIColor whiteColor] CGColor];
    _slider.layer.borderWidth = 2.f;
    [_brightnessBar addSubview:_slider];
    [_slider makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_brightnessBar.left).offset((1.f - brightness) * (ContainerWidth - 40.f));
        make.centerY.equalTo(_brightnessBar);
        make.width.equalTo(@(2.f * _slider.layer.cornerRadius));
        make.height.equalTo(@(50.f));
    }];
}

- (void)cancel:(UIButton *)button {
    [self dismiss];
}

- (void)reset:(UIButton *)button {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:UserDefaultsThemeColorKey];
    [userDefaults synchronize];
    [self dismiss];
}

- (void)check:(UIButton *)button {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedColor = [NSKeyedArchiver archivedDataWithRootObject:_selectedColor];
    [userDefaults setObject:encodedColor forKey:UserDefaultsThemeColorKey];
    [userDefaults synchronize];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Color changed" message:@"Restart app to take full effect" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismiss];
    }];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:AnimationInterval animations:^{
        self.view.tag = 2; // ContainerState::Dock in JPTabViewController.h
        [self.right uninstall];
        [self.dock install];
        [self.view.superview layoutIfNeeded];
    }];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    for (UIView *view in _controlContainer.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.tintColor = _selectedColor;
        }
        else {
            view.backgroundColor = _selectedColor;
        }
    }
    
    _brightnessBar.color = [UIColor colorWithHue:hue saturation:saturation brightness:1.f alpha:1.f];
    
    UIView *palette = _pick.superview;
    [_pick updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(palette.left).offset(CGRectGetWidth(palette.frame) * hue);
        make.centerY.equalTo(palette.top).offset(CGRectGetHeight(palette.frame) * (1.f - saturation));
    }];
    
    UIView *bar = _slider.superview;
    [_slider updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bar.left).offset(CGRectGetWidth(bar.frame) * (1.f - brightness));
    }];
}

- (void)palettePan:(UIPanGestureRecognizer *)pan {
    UIView *palette = pan.view;
    
    CGFloat offsetX = MAX([pan locationInView:palette].x, 0.f);
    offsetX = MIN(offsetX, CGRectGetWidth(palette.frame));
    CGFloat offsetY = MAX([pan locationInView:palette].y, 0.f);
    offsetY = MIN(offsetY, CGRectGetHeight(palette.frame));
    
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newHue = offsetX / CGRectGetWidth(palette.frame);
    CGFloat newSaturation = 1.f - offsetY / CGRectGetHeight(palette.frame);
    self.selectedColor = [UIColor colorWithHue:newHue saturation:newSaturation brightness:brightness alpha:alpha];
}

- (void)barPan:(UIPanGestureRecognizer *)pan {
    CGFloat offsetX = MAX([pan locationInView:pan.view].x, 0.f);
    offsetX = MIN(offsetX, CGRectGetWidth(pan.view.frame));
   
    CGFloat hue, saturation, brightness, alpha;
    [_selectedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newBrightness = 1.f - offsetX / CGRectGetWidth(pan.view.frame);
    self.selectedColor = [UIColor colorWithHue:hue saturation:saturation brightness:newBrightness alpha:alpha];
}

#pragma make - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    CGFloat inset = 5.f, width = _cellSize.width, height = _cellSize.height;
    
    UIView *colorCircle = [[UIView alloc] initWithFrame:(CGRect){inset, inset, width - 2.f * inset, width - 2.f * inset}];
    colorCircle.backgroundColor = _colors[indexPath.row];
    colorCircle.layer.borderColor = [[UIColor whiteColor] CGColor];
    colorCircle.layer.borderWidth = 5.f;
    colorCircle.layer.cornerRadius = width / 2.f - inset;
    [cell addSubview:colorCircle];
    
    CGFloat offsetY = inset + width + inset;
    UILabel *colorName = [[UILabel alloc] initWithFrame:(CGRect){0, offsetY, width, height - offsetY - inset}];
    colorName.font = [UIFont systemFontOfSize:11];
    colorName.textAlignment = NSTextAlignmentCenter;
    colorName.textColor = [UIColor whiteColor];
    colorName.text = _colorNames[indexPath.row];
    [cell addSubview:colorName];
    
    return cell;
}

#pragma make - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedColor = _colors[indexPath.row];
}

@end

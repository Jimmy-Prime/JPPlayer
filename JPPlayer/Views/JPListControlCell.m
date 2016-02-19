//
//  JPListControlCell.m
//  JPPlayer
//
//  Created by Prime on 2/16/16.
//  Copyright © 2016 Prime. All rights reserved.
//

#import "JPListControlCell.h"

@interface JPListControlCell()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *captionLabel;

@end

@implementation JPListControlCell

- (instancetype)init {
    UIImage *image = [UIImage imageNamed:@"ic_sort_white_48pt"];
    return [self initWithImage:image andCaption:@"Default"];
}

- (instancetype)initWithImage:(UIImage *)image andCaption:(NSString *)caption {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.tintColor = [UIColor redColor];
        [self addSubview:_imageView];
        [_imageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(_imageView.width);
        }];
        
        _captionLabel = [[UILabel alloc] init];
        _captionLabel.font = [UIFont systemFontOfSize:12.f];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
        _captionLabel.textColor = [UIColor whiteColor];
        _captionLabel.text = caption;
        [self addSubview:_captionLabel];
        [_captionLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-5.f);
            make.left.right.equalTo(self);
            make.height.equalTo(@(14));
        }];
    }
    
    return self;
}

@end

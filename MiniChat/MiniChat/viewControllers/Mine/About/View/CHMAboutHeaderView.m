//
//  CHMAboutHeaderView.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMAboutHeaderView.h"

CGFloat const logoWidth = 83.5;

@interface CHMAboutHeaderView ()
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation CHMAboutHeaderView


- (void)layoutSubviews {
    [super layoutSubviews];
    self.logoImageView.frame = CGRectMake((SCREEN_WIDTH - logoWidth) / 2.0 , 20, logoWidth, logoWidth);
    self.nameLabel.frame = CGRectMake(0, 20 + logoWidth + 5, SCREEN_WIDTH, 25);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance {
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = [UIImage imageNamed:@"logo"];
    [self addSubview:logoImageView];
    self.logoImageView = logoImageView;
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"博信";
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textColor = [UIColor chm_colorWithHexString:@"#999999" alpha:1.0];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nameLabel];
}



@end

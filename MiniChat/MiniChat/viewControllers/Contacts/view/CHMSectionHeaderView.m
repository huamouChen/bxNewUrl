//
//  CHMSeationHeaderView.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMSectionHeaderView.h"
#import "Masonry.h"

static NSString *const reuseIdentifier = @"CHMSeationHeaderView";

@interface CHMSectionHeaderView ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation CHMSectionHeaderView

+ (instancetype)headerWithTableView:(UITableView *)tableView {
    CHMSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (!header) {
        header = [[self alloc] initWithReuseIdentifier:reuseIdentifier];
    }
    return header;
}

#pragma mark - 构造函数
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupAppearance];
    }
    return self;
}


/**
 设置外观
 */
- (void)setupAppearance {
    self.contentView.backgroundColor = [UIColor chm_colorWithHexString:KSectionBgColor alpha:1.0];
    // 1.添加控件
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 2.自动布局
    __weak typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).offset(KMargin10);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
}

#pragma mark - setter && getter
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setTitleFont:(CGFloat)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = [UIFont systemFontOfSize:titleFont];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

- (void)setTextAligment:(NSTextAlignment)textAligment {
    _textAligment = textAligment;
    _titleLabel.textAlignment = textAligment;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel initWithString:@"" fontSize:12 textColor:[UIColor chm_colorWithHexString:KColor7 alpha:1.0]];
    }
    return _titleLabel;
}


@end

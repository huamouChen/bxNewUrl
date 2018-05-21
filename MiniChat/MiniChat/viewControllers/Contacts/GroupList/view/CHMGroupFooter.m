//
//  CHMGroupFooter.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/5.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupFooter.h"

static NSString *const footerReuseId = @"CHMGroupFooter";



@implementation CHMGroupFooter

+ (instancetype)footerWithTableView:(UITableView *)tableView {
    CHMGroupFooter *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerReuseId];
    if (!footer) {
        footer = [[self alloc] initWithReuseIdentifier:footerReuseId];
    }
    footer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    return footer;
}


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.footerTitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.footerTitleLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
}

- (UILabel *)footerTitleLabel {
    if (!_footerTitleLabel) {
        _footerTitleLabel = [[UILabel alloc] init];
        _footerTitleLabel.textColor = [UIColor chm_colorWithHexString:KColor7 alpha:1.0];
        _footerTitleLabel.font = [UIFont systemFontOfSize:15];
        _footerTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _footerTitleLabel;
}

@end

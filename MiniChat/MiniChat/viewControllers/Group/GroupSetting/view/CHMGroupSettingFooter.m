//
//  CHMGroupSettingFooter.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupSettingFooter.h"

static NSString *const reuseId = @"CHMGroupSettingFooter";

@interface CHMGroupSettingFooter ()


@end

@implementation CHMGroupSettingFooter


/**
 点击按钮
 */
- (void)dismissButtonClick {
    if (self.dismissButtonClickBlock) {
        self.dismissButtonClickBlock();
    }
}

+ (instancetype)groupSettingFooterViewTableView:(UITableView *)tableView {
    CHMGroupSettingFooter *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseId];
    if (!footer) {
        footer = [[self alloc] initWithReuseIdentifier:reuseId];
    }
    footer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 104);
    return footer;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.dismissButton];
    }
    return self;
}

- (void)layoutSubviews {
    self.dismissButton.frame = CGRectMake(16, 30, SCREEN_WIDTH - 16 * 2, 44);
}



- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.backgroundColor = [UIColor redColor];
        _dismissButton.layer.cornerRadius = 5;
        _dismissButton.layer.masksToBounds = YES;
        [_dismissButton addTarget:self action:@selector(dismissButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

@end

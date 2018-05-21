//
//  CHMUserDetailFooter.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserDetailFooter.h"

static NSString *const reuseIdentifier = @"reuseIdentifier";

@interface CHMUserDetailFooter ()
@property (weak, nonatomic) IBOutlet UIButton *footerButton;


@end

@implementation CHMUserDetailFooter


/**
 点击发送消息
 */
- (IBAction)sendMessageButtonClick {
    if (self.sendMessageBlock) {
        self.sendMessageBlock();
    }
}


- (void)setFooterTitler:(NSString *)footerTitler {
    _footerTitler = footerTitler;
    [_footerButton setTitle:_footerTitler forState:UIControlStateNormal];
}

+ (instancetype)footerWithTableView:(UITableView *)tableView {
    CHMUserDetailFooter *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (!header) {
        header = [[self alloc] initWithReuseIdentifier:reuseIdentifier];
    }
    return header;
}

#pragma mark - 构造函数
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self = [[[UINib nibWithNibName:NSStringFromClass([CHMUserDetailFooter class]) bundle:nil] instantiateWithOwner:self options:nil] lastObject];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 104);
}




@end

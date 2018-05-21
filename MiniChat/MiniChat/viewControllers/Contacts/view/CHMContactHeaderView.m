//
//  CHMContactHeaderView.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMContactHeaderView.h"


@interface CHMContactHeaderView ()


@end

@implementation CHMContactHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self = [[[UINib nibWithNibName:NSStringFromClass([CHMContactHeaderView class]) bundle:nil] instantiateWithOwner:self options:nil] lastObject];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

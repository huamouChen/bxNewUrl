//
//  RCDCSButton.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSButton.h"

@implementation RCDCSButton
- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    [self setTitleColor:[UIColor chm_colorWithHexString:@"0x939dab" alpha:1.0] forState:UIControlStateNormal];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor chm_colorWithHexString:@"0xb4bdcd" alpha:1.0].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
  }
  return self;
}

- (void)setSelected:(BOOL)selected{
  if (selected) {
    self.backgroundColor = [UIColor chm_colorWithHexString:@"0xe3eeff" alpha:1.0];
    self.layer.borderColor = [UIColor chm_colorWithHexString:@"0x91bcff" alpha:1.0].CGColor;
    [self setTitleColor:[UIColor chm_colorWithHexString:@"0x4d8df0" alpha:1.0] forState:UIControlStateNormal];
  }else{
    [self setTitleColor:[UIColor chm_colorWithHexString:@"0x939dab" alpha:1.0] forState:UIControlStateNormal];
    self.layer.borderColor = [UIColor chm_colorWithHexString:@"0xb4bdcd" alpha:1.0].CGColor;
    self.backgroundColor = [UIColor chm_colorWithHexString:@"0xffffff" alpha:1.0];
  }
  super.selected = selected;
}
@end

//
//  UILabel+CHMLabel.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "UILabel+CHMLabel.h"

@implementation UILabel (CHMLabel)
+ (instancetype)initWithString:(NSString *)string fontSize:(CGFloat)size textColor:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.text = string;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    [label sizeToFit];
    return label;
}
@end

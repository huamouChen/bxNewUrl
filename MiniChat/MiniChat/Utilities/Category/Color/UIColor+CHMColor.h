//
//  UIColor+CHMColor.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CHMColor)
+ (UIColor *)chm_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// UIColor 转UIImage
+ (UIImage *)chm_imageWithColor:(UIColor *)color;
@end

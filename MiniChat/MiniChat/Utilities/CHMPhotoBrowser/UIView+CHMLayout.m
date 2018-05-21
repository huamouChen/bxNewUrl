//
//  UIView+CHMLayout.m
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import "UIView+CHMLayout.h"

@implementation UIView (CHMLayout)
// chm_x
- (void)setChm_x:(CGFloat)chm_x {
    CGRect frame = self.frame;
    frame.origin.x = chm_x;
    self.frame = frame;
}
- (CGFloat)chm_x {
    return self.frame.origin.x;
}

// chm_y
- (void)setChm_y:(CGFloat)chm_y {
    CGRect frame = self.frame;
    frame.origin.y = chm_y;
    self.frame = frame;
}
- (CGFloat)chm_y {
    return self.frame.origin.y;
}

// width
- (void)setChm_width:(CGFloat)chm_width {
    CGRect frame = self.frame;
    frame.size.width = chm_width;
    self.frame = frame;
}
- (CGFloat)chm_width {
    return self.frame.size.width;
}

// height
- (void)setChm_height:(CGFloat)chm_height {
    CGRect frame = self.frame;
    frame.size.height = chm_height;
    self.frame = frame;
}
- (CGFloat)chm_height {
    return self.frame.size.height;
}

// centerX
- (void)setChm_centerX:(CGFloat)chm_centerX {
//    CGRect frame = self.frame;
//    frame.origin.x = chm_centerX - (self.frame.size.width / 2.0);
//    self.frame = frame;
    self.center = CGPointMake(chm_centerX, self.center.y);
}
- (CGFloat)chm_centerX {
//    return self.frame.origin.x + (self.frame.size.width / 2.0);
    return self.center.x;
}

// centerY
- (void)setChm_centerY:(CGFloat)chm_centerY {
//    CGRect frame = self.frame;
//    frame.origin.y = chm_centerY - (self.frame.size.height / 2.0);
//    self.frame = frame;
    self.center = CGPointMake(self.center.x, chm_centerY);
}
- (CGFloat)chm_centerY {
//    return self.frame.origin.x + (self.frame.size.height / 2.0);
    return self.center.y;
}

// origin
- (void)setChm_origin:(CGPoint)chm_origin {
    CGRect frame = self.frame;
    frame.origin = chm_origin;
    self.frame = frame;
}
- (CGPoint)chm_origin {
    return self.frame.origin;
}

// size
- (void)setChm_size:(CGSize)chm_size {
    CGRect frame = self.frame;
    frame.size = chm_size;
    self.frame = frame;
}
- (CGSize)chm_size {
    return self.frame.size;
}

@end

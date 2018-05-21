//
//  UIView+CHMLayout.h
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CHMLayout)
/** 快捷方式 frame.origin.x */
@property(nonatomic, assign) CGFloat chm_x;
/** 快捷方式 frame.origin.y */
@property(nonatomic, assign) CGFloat chm_y;
/** 快捷方式 frame.size.width */
@property(nonatomic, assign) CGFloat chm_width;
/** 快捷方式 frame.size.height */
@property(nonatomic, assign) CGFloat chm_height;
/** 快捷方式 center.x */
@property(nonatomic, assign) CGFloat chm_centerX;
/** 快捷方式 center.y */
@property(nonatomic, assign) CGFloat chm_centerY;
/** 快捷方式 frame.origin */
@property(nonatomic, assign) CGPoint chm_origin;
/** 快捷方式 frame.size */
@property(nonatomic, assign) CGSize chm_size;
@end

//
//  UIImage+CHMImage.h
//  MiniChat
//
//  Created by 陈华谋 on 04/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CHMImage)

/**
 *  修改图片size
 *
 *  @param image      原图片
 *  @param targetSize 要修改的size
 *
 *  @return 修改后的图片
 */
+ (UIImage *)chm_image:(UIImage *)image byScalingToSize:(CGSize)targetSize;

@end

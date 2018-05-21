//
//  CHMPhotoBrowserController.h
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CHMPhotoBrowserTransition) {
    CHMPhotoBrowserTransitionPresent,
    CHMPhotoBrowserTransitionPush
};

@interface CHMPhotoBrowserController : UIViewController

/**
 创建一个图片浏览控制器

 @param photosArray 图片数组
 @param currentIndex 当前选择的图片下标
 @param transitonStyle 呈现方式 Present Push
 @return 创建好的图片浏览器
 */
- (instancetype)initWithPhotosArray:(NSArray *)photosArray currentIndex:(NSInteger)currentIndex transitionStyle:(CHMPhotoBrowserTransition)transitonStyle;

/**
 是否显示页码
 */
@property (nonatomic, assign) BOOL isShowPageLabel;
@end

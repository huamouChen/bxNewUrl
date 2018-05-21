//
//  CHMPhotoBrowserCell.h
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHMPhotoBrowserView;

typedef void(^singleTapBlock)();

@interface CHMPhotoBrowserCell : UICollectionViewCell
@property (strong, nonatomic) CHMPhotoBrowserView *browserView;
/**
 图片的URL String
 */
@property (copy, nonatomic) NSString *urlString;

/**
 单击 block
 */
@property (copy, nonatomic) singleTapBlock singleTap;

/**
 恢复到初始状态
 */
- (void)recoverSubviews;
@end



@interface CHMPhotoBrowserView : UIView
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *imageContainerView;
@property (strong, nonatomic) UIImageView *imageView;

/**
 图片的URL String
 */
@property (copy, nonatomic) NSString *urlString;

/**
 单击 block
 */
@property (copy, nonatomic) singleTapBlock singleTap;

/**
 恢复到初始状态
 */
- (void)recoverSubviews;
@end

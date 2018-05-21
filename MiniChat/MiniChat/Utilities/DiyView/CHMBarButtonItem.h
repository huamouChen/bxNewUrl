//
//  CHMBarButtonItem.h
//  MiniChat
//
//  Created by 陈华谋 on 04/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHMBarButtonItem : UIBarButtonItem

@property(nonatomic, strong) UIButton *button;

//初始化包含图片的
- (instancetype)initWithLeftBarButton:(NSString *)title target:(id)target action:(SEL)method;

//初始化包含图片的UIBarButtonItem
- (instancetype)initContainImage:(UIImage *)buttonImage
                          imageViewFrame:(CGRect)imageFrame
                             buttonTitle:(NSString *)buttonTitle
                              titleColor:(UIColor *)titleColor
                              titleFrame:(CGRect)titleFrame
                             buttonFrame:(CGRect)buttonFrame
                                  target:(id)target
                                  action:(SEL)method;

//初始化不包含图片的UIBarButtonItem
- (instancetype)initWithbuttonTitle:(NSString *)buttonTitle
                                 titleColor:(UIColor *)titleColor
                                buttonFrame:(CGRect)buttonFrame
                                     target:(id)target
                                     action:(SEL)method;

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick
             buttonColor:(UIColor *)buttonColor
           barButtonItem:(CHMBarButtonItem *)barButtonItem;

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *)setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation;
@end



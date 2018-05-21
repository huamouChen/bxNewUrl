//
//  CHMBarButtonItem.m
//  MiniChat
//
//  Created by 陈华谋 on 04/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMBarButtonItem.h"
@interface CHMBarButtonItem ()

@property(nonatomic, strong) UILabel *titleText;

@end

@implementation CHMBarButtonItem
- (instancetype)initWithLeftBarButton:(NSString *)title target:(id)target action:(SEL)method{
    CGRect titleFrame = CGRectMake(15, 4, 85, 17);
    if (title.length == 0) {
        titleFrame = CGRectZero;
    }
    return [self initContainImage:[UIImage imageNamed:@"back"] imageViewFrame:CGRectMake(0, 0, 12, 20) buttonTitle:title titleColor:[UIColor chm_colorWithHexString:@"#ffffff" alpha:1.0] titleFrame:CGRectMake(15, 4, 85, 17) buttonFrame:CGRectMake(-4, 0, 87, 23) target:target action:method];
}



//初始化包含图片的UIBarButtonItem
- (instancetype)initContainImage:(UIImage *)buttonImage
                  imageViewFrame:(CGRect)imageFrame
                     buttonTitle:(NSString *)buttonTitle
                      titleColor:(UIColor *)titleColor
                      titleFrame:(CGRect)titleFrame
                     buttonFrame:(CGRect)buttonFrame
                          target:(id)target
                          action:(SEL)method {
    
    if (self = [super init]) {
        UIView *view = [[UIView alloc] initWithFrame:buttonFrame];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = buttonFrame;
        UIImageView *image = [[UIImageView alloc] initWithImage:buttonImage];
        image.frame = imageFrame;
        if (!buttonTitle) {
            image.center = view.center;
        }
        
        [self.button addSubview:image];
        if (buttonTitle != nil && titleColor != nil) {
            self.titleText = [[UILabel alloc] initWithFrame:titleFrame];
            self.titleText.text = buttonTitle;
            [self.titleText setBackgroundColor:[UIColor clearColor]];
            [self.titleText setTextColor:titleColor];
            [self.button addSubview:self.titleText];
        }
        [self.button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:self.button];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:method];
        [view addGestureRecognizer:tap];
        self.customView = view;
    }
    
    
    return self;
}

//初始化不包含图片的UIBarButtonItem
- (instancetype)initWithbuttonTitle:(NSString *)buttonTitle
                         titleColor:(UIColor *)titleColor
                        buttonFrame:(CGRect)buttonFrame
                             target:(id)target
                             action:(SEL)method {
    if (self = [super init]) {
        self.button = [[UIButton alloc] initWithFrame:buttonFrame];
        [self.button setTitle:buttonTitle forState:UIControlStateNormal];
        [self.button setTitleColor:titleColor forState:UIControlStateNormal];
        [self.button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
        self.button.titleLabel.font = [UIFont systemFontOfSize:16];
        self.customView = self.button;
    }
    
    return self;
}

//设置UIBarButtonItem是否可以被点击和对应的颜色
- (void)buttonIsCanClick:(BOOL)isCanClick
             buttonColor:(UIColor *)buttonColor
           barButtonItem:(CHMBarButtonItem *)barButtonItem {
    if (isCanClick == YES) {
        barButtonItem.customView.userInteractionEnabled = YES;
    } else {
        barButtonItem.customView.userInteractionEnabled = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (buttonColor != nil) {
            if (barButtonItem.titleText != nil) {
                [barButtonItem.titleText setTextColor:buttonColor];
            } else {
                [barButtonItem.button setTitleColor:buttonColor forState:UIControlStateNormal];
                barButtonItem.customView = barButtonItem.button;
            }
        }
    });
}

//平移UIBarButtonItem
- (NSArray<UIBarButtonItem *> *)setTranslation:(UIBarButtonItem *)barButtonItem translation:(CGFloat)translation {
    if (barButtonItem == nil) {
        return nil;
    }
    
    NSArray<UIBarButtonItem *> *barButtonItems;
    UIBarButtonItem *negativeSpacer =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = translation;
    
    barButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];
    
    return barButtonItems;
}
@end

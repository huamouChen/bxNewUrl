//
//  Constants.h
//  MiniChat
//
//  Created by 陈华谋 on 29/04/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


// 融云 AppKey

#ifdef DEBUG
#define RongCloudAppKey   @"cpj2xarlc74vn"
// 客服 ID
#define SERVICE_ID @"KEFU152410101210011"
#else
#define RongCloudAppKey   @"pgyu6atqpefzu"
// 客服 ID
#define SERVICE_ID @"KEFU152600331440927"
#endif


#ifdef DEBUG
#define NSLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
//#define NSLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
 #define NSLog(...)
#endif


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define KTouchBarHeight 34.0f
#define KISIphoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))


#define IOS_FSystenVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

#define KNavigationBar88    88.0
#define KNavigationBar64    64.0
#define KNavigationBar44    44.0
#define KTabBar49    49.0
#define KMargin10    10.0f

// 弱引用、强引用
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;


// 由角度转换弧度
#define KDegressToRadian(x)  (M_PI * x) / 180.0
// 由弧度转换角度
#define kRadianToDegrees(radian) (radian * 180.0) / M_PI

#endif /* Constants_h */

//
//  CHMProgressHUD.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMProgressHUD.h"

@implementation CHMProgressHUD

+ (void)showWithInfo:(NSString *)info isHaveMask:(BOOL)isHaveMask {
    
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    
    if (isHaveMask) {
        [CHMProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [CHMProgressHUD showWithStatus:info];
        [CHMProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        
    } else {
        [CHMProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [CHMProgressHUD showWithStatus:info];
    }
}

+ (void)showSuccessWithInfo:(NSString *)info {
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [CHMProgressHUD showSuccessWithStatus:info];
}

+ (void)showErrorWithInfo:(NSString *)info {
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [CHMProgressHUD showErrorWithStatus:info];
}

+ (void)dismissHUD {
    [CHMProgressHUD dismiss];
}

// 显示时长
+ (NSTimeInterval)displayDurationForString:(NSString *)string {
    if (string.length < 10) {
        return 1;
    } else if (string.length > 10 && string.length < 20) {
        return 1.5;
    } else {
        return 2;
    }
}

@end

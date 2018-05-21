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
    if (isHaveMask) {
        [CHMProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [CHMProgressHUD showWithStatus:info];
        [CHMProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    } else {
        [CHMProgressHUD showWithStatus:info];
    }
}

+ (void)showSuccessWithInfo:(NSString *)info {
    [CHMProgressHUD showSuccessWithStatus:info];
}

+ (void)showErrorWithInfo:(NSString *)info {
    [CHMProgressHUD showErrorWithStatus:info];
}

+ (void)dismissHUD {
    [CHMProgressHUD dismiss];
}

@end

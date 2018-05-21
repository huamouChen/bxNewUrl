//
//  CHMProgressHUD.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

@interface CHMProgressHUD : SVProgressHUD


+ (void)showWithInfo:(NSString *)info isHaveMask:(BOOL)isHaveMask;


+ (void)showSuccessWithInfo:(NSString *)info;

+ (void)showErrorWithInfo:(NSString *)info;

+ (void)dismissHUD;

@end

//
//  CHMRongTokenResponse.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CodeBean, ValueBean;

@interface CHMRongTokenResponse : NSObject

@property (nonatomic, strong) CodeBean *Code;
@property (nonatomic, strong) ValueBean *Value;
@end







@interface CodeBean : NSObject

@property (nonatomic, copy) NSString *CodeId;
@property (nonatomic, copy) NSString *Description;

@end


@interface ValueBean : NSObject

@property (nonatomic, copy) NSString *AddTime;
@property (nonatomic, copy) NSString *RongToken;
@property (nonatomic, copy) NSString *UserName;


@end

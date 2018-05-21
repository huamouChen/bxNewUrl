//
//  CHMFriendModel.m
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMFriendModel.h"

@implementation CHMFriendModel
- (instancetype)initWithUserId:(NSString *)userId nickName:(NSString *)nickName portrait:(NSString *)portrait {
    if (self = [super init]) {
        _UserName = userId;
        _NickName = nickName;
        _HeaderImage = portrait;
        _IsOnLine = @"01";
        _isCheck = NO;
    }
    return self;
}
@end

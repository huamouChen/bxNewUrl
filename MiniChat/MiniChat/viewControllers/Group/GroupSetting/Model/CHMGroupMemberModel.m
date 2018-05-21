//
//  CHMGroupMemberModel.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupMemberModel.h"

@implementation CHMGroupMemberModel


- (instancetype)initWithUserName:(NSString *)userName nickName:(NSString *)nickName headerImage:(NSString *)headerImage groupId:(NSString *)groupId {
    if (self = [super init]) {
        _UserName = userName;
        _NickName = nickName;
        _HeaderImage = headerImage;
        _GroupId = groupId;
    }
    return self;
}

@end

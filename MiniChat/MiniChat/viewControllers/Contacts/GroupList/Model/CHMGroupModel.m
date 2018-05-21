//
//  CHMGroupModel.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/5.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupModel.h"

@implementation CHMGroupModel

- (instancetype)initWithGroupId:(NSString *)groupId groupName:(NSString *)groupName groupPortrait:(NSString *)groupPortrait {
    if (self = [super init]) {
        self.GroupId = groupId;
        self.GroupName = groupName;
        self.GroupImage = groupPortrait;
    }
    return self;
}

@end

//
//  CHMGroupModel.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/5.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHMGroupModel : NSObject
@property (nonatomic, copy) NSString *AddTime;
@property (nonatomic, copy) NSString *CanBetting;
@property (nonatomic, copy) NSString *GroupId;
@property (nonatomic, copy) NSString *GroupImage;
@property (nonatomic, copy) NSString *GroupName;
@property (nonatomic, copy) NSString *GroupOwner;
@property (nonatomic, copy) NSString *IsOfficial;
@property (nonatomic, copy) NSString *State;

@property (nonatomic, copy) NSString *Bulletin;


- (instancetype)initWithGroupId:(NSString *)groupId groupName:(NSString *)groupName groupPortrait:(NSString *)groupPortrait;
@end

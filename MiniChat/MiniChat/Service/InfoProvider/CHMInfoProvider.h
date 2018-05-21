//
//  CHMInfoProvider.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>


#define CHMIMDataSourece [CHMInfoProvider shareInstance];

@interface CHMInfoProvider : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMGroupUserInfoDataSource>


+ (instancetype)shareInstance;

#pragma mark - 从服务器获取
/**
 *  同步自己的所属群组到融云服务器,修改群组信息后都需要调用同步
 */
- (void)syncGroups;
/**
 更新单个群组的信息
 
 @param groupId 要更新的群组ID
 */
- (void)syncGroupWithGroupId:(NSString *)groupId;
/**
 更新单个群组的成员信息
 
 @param groupId 要更新的群组ID
 */
- (void)syncGroupMemberListWithGroupId:(NSString *)groupId;

/**
 *  获取群中的成员列表
 */
- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray *userIdList))resultBlock;

/**
 *  从服务器同步好友列表
 */
- (void)syncFriendList:(NSString *)userId complete:(void (^)(NSMutableArray *friends))completion;





#pragma mark - 从数据库获取
/*
 * 获取所有好友信息
 */
- (NSArray *)getAllFriends:(void (^)(void))completion;

/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)(void))completion;

/*
 * 获取所有用户信息
 */
- (NSArray *)getAllUserInfo:(void (^)(void))completion;


@end

//
//  CHMDataBaseManager.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/7.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CHMGroupModel, CHMGroupMemberModel;

@interface CHMDataBaseManager : NSObject

+ (instancetype)shareManager;

- (void)closeDBForDisconnect;

#pragma mark - 插入用户信息
/**
 存储用户信息

 @param user 要存储的用户
 */
- (void)insertUserToDB:(RCUserInfo *)user;
/**
 存储一组用户信息

 @param userList 要存储的用户信息组
 @param result 是否成功
 */
- (void)insertUserListToDB:(NSMutableArray *)userList complete:(void (^)(BOOL))result;

#pragma mark - 插入好友信息
/**
 存储好友信息

 @param friendInfo 要存储的好友
 */
- (void)insertFriendToDB:(RCUserInfo *)friendInfo;

/**
 存储一组好友信息

 @param FriendList 要存储的一组好友信息
 @param result 是否成功
 */
- (void)insertFriendListToDB:(NSMutableArray *)FriendList complete:(void (^)(BOOL))result;

#pragma mark - 插入群组信息

/**
 插入群组信息

 @param group 要存储的群组
 */
- (void)insertGroupToDB:(CHMGroupModel *)group;

/**
 插入一组群组信息

 @param groupList 要存储的一组群组信息
 @param result 是否成功
 */
- (void)insertGroupsToDB:(NSMutableArray *)groupList complete:(void (^)(BOOL))result;


/**
 更新单个群成员的信息
 
 @param member 要更新的成员
 @param groupId 对应的群组
 @param result 是否成功
 */
- (void)updateMember:(RCUserInfo *)member toGroupId:(NSString *)groupId complete:(void (^)(BOOL))result;

//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result;

// 删除群组成员信息
- (void)deleteGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result;





#pragma mark - 取信息
//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId;

// 获取所有好友
- (NSArray *)getAllFriends;

//从表中获取所有用户信息
- (NSArray *)getAllUserInfo;

//从表中获取某个好友的信息
- (RCUserInfo *)getFriendInfo:(NSString *)friendId;

#pragma mark - 获取群组信息
//从表中获取群组信息
- (CHMGroupModel *)getGroupByGroupId:(NSString *)groupId;

//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId;

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup;

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId;

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB;



@end

//
//  CHMInfoProvider.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMInfoProvider.h"
#import "CHMDataBaseManager.h"
#import "CHMGroupModel.h"
#import "CHMGroupMemberModel.h"
#import "CHMFriendModel.h"
#import "CHMUserInfoManager.h"
#import "CHMGroupTipMessage.h"

@implementation CHMInfoProvider

+ (instancetype)shareInstance {
    static CHMInfoProvider *infoProvider = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!infoProvider) {
            infoProvider = [[CHMInfoProvider alloc] init];
        }
    });
    return infoProvider;
}

#pragma mark - 从服务器获取数据
- (void)syncGroups {
    [CHMHttpTool getGroupListWithSuccess:^(id response) {
        NSLog(@"------------%@", response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            // 群组信息
            NSArray *groupList = [CHMGroupModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            // 保存数据到本地
            for (CHMGroupModel *groupModel in groupList) {
                NSString *groupImage = [NSString stringWithFormat:@"%@%@", BaseURL, groupModel.GroupImage];
                groupModel.GroupImage = groupImage;
                [[CHMDataBaseManager shareManager] insertGroupToDB:groupModel];
            }
            
            
            // 群组成员信息
            for (CHMGroupModel *group in groupList) {
                [CHMHttpTool getGroupMembersWithGroupId:group.GroupId success:^(id response) {
                    NSLog(@"--------%@",response);
                    NSNumber *codeId = response[@"Code"][@"CodeId"];
                    if (codeId.integerValue == 100) {
                        NSMutableArray *groupMemberArray = [CHMGroupMemberModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
                        [[CHMDataBaseManager shareManager] insertGroupMemberToDB:groupMemberArray groupId:group.GroupId complete:^(BOOL result){ }];
                    } else {
//                        [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
                    }
                } failure:^(NSError *error) {
//                    [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
                }];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"-------%zd", error.code);
    }];
}

/**
 更新单个群组的信息

 @param groupId 要更新的群组ID
 */
- (void)syncGroupWithGroupId:(NSString *)groupId {
    [CHMHttpTool getGroupInfoWithGroupId:groupId success:^(id response) {
        NSLog(@"--------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSString *groupName = [NSString stringWithFormat:@"%@",response[@"Value"][@"GroupName"]];
            NSString *groupImage = [NSString stringWithFormat:@"%@%@",BaseURL, response[@"Value"][@"GroupImage"]];
            NSString *addTime = [NSString stringWithFormat:@"%@",response[@"Value"][@"AddTime"]];
            NSString *canBetting = [NSString stringWithFormat:@"%@", response[@"Value"][@"CanBetting"]];
            NSString *groupOwner = [NSString stringWithFormat:@"%@", response[@"Value"][@"GroupOwner"]];
            NSString *isOfficial = [NSString stringWithFormat:@"%@", response[@"Value"][@"IsOfficial"]];
            NSString *groupState = [NSString stringWithFormat:@"%@", response[@"Value"][@"State"]];
            CHMGroupModel *groupModel = [[CHMGroupModel alloc] initWithGroupId:groupId groupName:groupName groupPortrait:groupImage];
            groupModel.AddTime = addTime;
            groupModel.CanBetting = canBetting;
            groupModel.GroupOwner = groupOwner;
            groupModel.IsOfficial = isOfficial;
            groupModel.State = groupState;
            // 保存到本地
            [[CHMDataBaseManager shareManager] insertGroupToDB:groupModel];
        } else {
//            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
//        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
    }];
}

/**
 更新单个群组的成员信息

 @param groupId 要更新的群组ID
 */
- (void)syncGroupMemberListWithGroupId:(NSString *)groupId {
    [CHMHttpTool getGroupMembersWithGroupId:groupId success:^(id response) {
        NSLog(@"--------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSMutableArray *filterArrary = [NSMutableArray array];
            NSArray *groupMemberArray = [CHMGroupMemberModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            for (CHMGroupMemberModel *memberModel in groupMemberArray) {
                if ([memberModel.NickName isKindOfClass:[NSNull class]] || memberModel.NickName == nil || [memberModel.NickName isEqualToString:@""]) {
                    memberModel.NickName = memberModel.UserName;
                }
                [filterArrary addObject:memberModel];
            }
            
            
            // 保存到本地
            [[CHMDataBaseManager shareManager] insertGroupMemberToDB:filterArrary groupId:groupId complete:^(BOOL isComplete) { }];
        } else {
//            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
//        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
    }];
}


- (void)syncFriendList:(NSString *)userId complete:(void (^)(NSMutableArray *friends))completion {
    [CHMHttpTool getUserRelationShipListWithSuccess:^(id response) {
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSMutableArray *friendsArray = [CHMFriendModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            // 处理没有昵称的问题
            NSMutableArray *filterArray = [self dealWithNickNameWithArray:friendsArray];
            // 把当前用户也作为一个好友添加进去
            // 从沙盒中取登录时保存的用户信息
            NSString *nickName = [[NSUserDefaults standardUserDefaults] valueForKey:KNickName];
            NSString *account = [[NSUserDefaults standardUserDefaults] valueForKey:KAccount];
            NSString *portrait = [[NSUserDefaults standardUserDefaults] valueForKey:KPortrait];
            CHMFriendModel *currentuser = [[CHMFriendModel alloc] initWithUserId:account nickName:nickName portrait:portrait];
            [filterArray addObject:currentuser];
            
            // 保存到数据库
            for (CHMFriendModel *friendModel in filterArray) {
                RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:friendModel.UserName name:friendModel.NickName portrait:friendModel.HeaderImage];
                [[CHMDataBaseManager shareManager] insertFriendToDB:userInfo];
            }
            completion(filterArray);
            
        } else {
            // 失败暂时不提醒
        }
    } failure:^(NSError *error) {
//        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%zd", error.code]];
    }];
}

/**
 处理头像 或者昵称为空
 */
- (NSMutableArray *)dealWithNickNameWithArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (CHMFriendModel *itemModel in array) {
        if ([itemModel.NickName isKindOfClass:[NSNull class]] || [itemModel.NickName isEqualToString:@""] || itemModel.NickName == nil) {
            itemModel.NickName = itemModel.UserName;
        }
        if ([itemModel.HeaderImage isKindOfClass:[NSNull class]] || [itemModel.HeaderImage isEqualToString:@""] || itemModel.HeaderImage == nil) {
            itemModel.HeaderImage = @"icon_person";
        } else {
            itemModel.HeaderImage = [NSString stringWithFormat:@"%@%@",BaseURL, itemModel.HeaderImage];
        }
        
        [resultArray addObject:itemModel];
    }
    return resultArray;
}

- (void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray *userIdList))resultBlock {
    
    [CHMHttpTool getGroupMembersWithGroupId:groupId success:^(id response) {
        NSLog(@"--------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSMutableArray *groupMemberArray = [CHMGroupMemberModel mj_objectArrayWithKeyValuesArray:response[@"Value"]];
            resultBlock(groupMemberArray);
            
        } else {
            [CHMProgressHUD showErrorWithInfo:response[@"Code"][@"Description"]];
        }
    } failure:^(NSError *error) {
        [CHMProgressHUD showErrorWithInfo:[NSString stringWithFormat:@"错误码--%ld", (long)error.code]];
    }];
}

#pragma mark - 从数据查询数据
// 获取好友
- (NSArray *)getAllFriends:(void (^)(void))completion {
    return [[CHMDataBaseManager shareManager] getAllFriends];
}

// 获取群组
- (NSArray *)getAllGroupInfo:(void (^)(void))completion {
    return [[CHMDataBaseManager shareManager] getAllGroup];
}

// 获取所有用户信息

- (NSArray *)getAllUserInfo:(void (^)(void))completion {
    return [[CHMDataBaseManager shareManager] getAllUserInfo];
}


#pragma mark - RCIMUserInfoDataSource 用户信息提供者   群组信息提供者
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"%@", userId);
    RCUserInfo *user = nil;
    // 从数据库取
    user = [[CHMDataBaseManager shareManager] getUserByUserId:userId];
    if (user) {
        completion(user);
        return;
    }
    
    // userid 为空
    user = [RCUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user.userId = userId;
        user.portraitUri = KDefaultPortrait;
        user.name = userId;
        completion(user);
        return;
    }
    //开发者调自己的服务器接口根据userID异步请求数据
    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {  // 不是当前用户
        [[CHMUserInfoManager shareInstance] getFriendInfo:userId
                                               completion:^(RCUserInfo *user) {
                                                   completion(user);
                                               }];
    } else { // 当前登录的用户
        [[CHMUserInfoManager shareInstance] getUserInfo:userId
                                             completion:^(RCUserInfo *user) {
                                                 [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
                                                 completion([[RCIM sharedRCIM] currentUserInfo]);
                                             }];
    }
    return;
}

- (void)getGroupInfoWithGroupId:(NSString *)groupId completion:(void (^)(RCGroup *))completion {
    if ([groupId length] == 0)
        return;
    
    CHMGroupModel *groupModel = [[CHMDataBaseManager shareManager] getGroupByGroupId:groupId];
    if (groupModel) {
        RCGroup *group = [[RCGroup alloc] initWithGroupId:groupModel.GroupId groupName:groupModel.GroupName portraitUri:groupModel.GroupImage];
        completion(group);
        return;
    }
    
    //开发者调自己的服务器接口根据userID异步请求数据
    [CHMHttpTool getGroupInfoWithGroupId:groupId success:^(id response) {
        NSLog(@"--------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSString *groupName = response[@"Value"][@"GroupName"];
            NSString *groupImage = response[@"Value"][@"GroupImage"];
            groupImage = ([groupImage isKindOfClass:[NSNull class]] || [groupImage isEqualToString:@""]) ? KDefaultPortrait : [NSString stringWithFormat:@"%@%@",BaseURL, groupImage];
            RCGroup *group = [[RCGroup alloc] initWithGroupId:groupId groupName:groupName portraitUri:groupImage];
            completion(group);
        } else {
        }
    } failure:^(NSError *error) { }];
}

- (void)getUserInfoWithUserId:(NSString *)userId inGroup:(NSString *)groupId completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    RCUserInfo *user = [RCUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user.userId = userId;
        user.portraitUri = KDefaultPortrait;
        user.name = userId;
        completion(user);
        return;
    }
    //开发者调自己的服务器接口根据userID异步请求数据
    if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [[CHMUserInfoManager shareInstance] getFriendInfo:userId
                                               completion:^(RCUserInfo *user) {
                                                   completion(user);
                                               }];
    } else {
        [[CHMUserInfoManager shareInstance] getUserInfo:userId
                                             completion:^(RCUserInfo *user) {
                                                 [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];
                                                 
                                                 completion(user);
                                             }];
    }
    return;
}

@end

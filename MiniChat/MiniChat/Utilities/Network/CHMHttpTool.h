//
//  CHMHttpTool.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestMethodType) {
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2
};

typedef void(^successBlock)(id response);
typedef void(^failureBlock)(id error);
typedef void(^errorBlock)(NSError *error, id response);

@interface CHMHttpTool : NSObject


/**
 单例

 @return 当前唯一实例对象
 */
+ (instancetype)shareManager;

+ (void)requestWithMethod:(RequestMethodType)MethodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(successBlock) success
                  failure:(failureBlock)failure;



/**
 登录

 @param account 账号
 @param password 密码
 @param success 成功
 @param failure 失败
 */
+ (void)loginWithAccount:(NSString *)account password:(NSString *)password success:(successBlock)success failure:(failureBlock)failure;

/**
 注册
 
 @param account 账号
 @param password 密码
 @param bounds 返水
 @param userType 用户类型
 @param success 成功
 @param failure 失败
 */
+ (void)registerWithAccount:(NSString *)account password:(NSString *)password bounds:(NSString *)bounds userType:(NSString *)userType success:(successBlock)success failure:(failureBlock)failure;

/**
 修改密码
 
 @param oldPassword 旧密码
 @param newPassword 新密码
 @param  success 成功
 @param failure 失败
 */
+ (void)changePasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword success:(successBlock)success failure:(failureBlock)failure;


/**
 查询用户信息
 
 @param userId 用户ID
 @param success 成功
 @param failure 失败
 */
+ (void)searchUserInfoWithUserId:(NSString *)userId success:(successBlock)success failure:(failureBlock)failure;

/**
 获取用户信息

 @param userId 用户ID
 @param success 成功
 @param failure 失败
 */
+ (void)getUserInfoWithUserId:(NSString *)userId success:(successBlock)success failure:(failureBlock)failure;

/**
 修改昵称
 
 @param nickName 新的昵称
 @param success 成功
 @param failure 失败
 */
+ (void)setUserNickNameWithNickName:(NSString *)nickName success:(successBlock)success failure:(failureBlock)failure;

/**
 修改头像
 
 @param image 头像图片
 @param success 成功
 @param failure 失败
 */
+ (void)setUserPortraitWithImage:(UIImage *)image success:(successBlock)success failure:(failureBlock)failure;

/**
 绑定手机
 
 @param phoneNumber 要绑定的手机号码
 @param success 成功
 @param failure 失败
 */
+ (void)bindMobilePhoneWithPhoneNumber:(NSString *)phoneNumber success:(successBlock)success failure:(failureBlock)failure;

/**
 添加好友
 
 @param userId 要添加的用户ID
 @param mark 备注信息
 @param success 成功
 @param failure 失败
 */
+ (void)addFriendWithUserId:(NSString *)userId mark:(NSString *)mark success:(successBlock)success failure:(failureBlock)failure;

/**
 同意好友申请
 
 @param applyId 申请ID
 @param success 成功
 @param failure 失败
 */
+ (void)agreeFriendWithApplyId:(NSString *)applyId success:(successBlock)success failure:(failureBlock)failure;

/**
 获取聊天室列表

 @param success 成功
 @param failure 失败
 */
+ (void)getChatRoomListsWithSuccess:(successBlock)success failure:(failureBlock)failure;

/**
 获取用户关系列表
 
 @param success 成功
 @param failure 失败
 */
+ (void)getUserRelationShipListWithSuccess:(successBlock)success failure:(failureBlock)failure;

#pragma mark - 群组相关
/**
 创建群组
 
 @param groupName 群组名称
 @param groupMembers 群组成员
 @param groupPortrait 群组头像
 @param success 成功
 @param failure 失败
 */
+ (void)createGroupWtihGroupName:(NSString *)groupName groupMembers:(NSArray *)groupMembers groupPortrait:(UIImage *)groupPortrait success:(successBlock)success failure:(failureBlock)failure;

/**
 获取指定群组的信息
 
 @param groupId 要获取的群组ID
 @param success 成功
 @param failure 失败
 */
+ (void)getGroupInfoWithGroupId:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 修改群组头像
 
 @param groupId 群组ID
 @param image 群组头像
 @param success 成功
 @param failure 失败
 */
+ (void)setGroupPortraitWithGroupId:(NSString *)groupId groupPortrait:(UIImage *)image success:(successBlock)success failure:(failureBlock)failure;

/**
 获取群组的成员列表
 
 @param groupId 要获取的群组ID
 @param success 成功
 @param failure 失败
 */
+ (void)getGroupMembersWithGroupId:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 获取群聊列表
 
 @param success 成功
 @param failure 失败
 */
+ (void)getGroupListWithSuccess:(successBlock)success failure:(failureBlock)failure;

/**
 邀请加入群组
 
 @param groupId 群组ID
 @param groupName 群组名称
 @param memberArray 成员ID数组
 @param success 成功
 @param failure 失败
 */
+ (void)inviteMemberToGroup:(NSString *)groupId groupName:(NSString *)groupName members:(NSArray *)memberArray success:(successBlock)success failure:(failureBlock)failure;
/**
 群组踢人，只有群主才可以
 
 @param groupId 群组ID
 @param memberArray 成员ID数组
 @param success 成功
 @param failure 失败
 */
+ (void)kickMemberFromGroup:(NSString *)groupId  members:(NSArray *)memberArray success:(successBlock)success failure:(failureBlock)failure;
/**
 离开群组
 
 @param groupId 群组ID
 @param success 成功
 @param failure 失败
 */
+ (void)quitFromGroup:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 创建者解散群组
 
 @param groupId 群组ID
 @param success 成功
 @param failure 失败
 */
+ (void)dismissGroup:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 修改群名称
 
 @param groupName 新的群名称
 @param groupId 目标groupId
 @param success 成功
 @param failure 失败
 */
+ (void)modifyGroupName:(NSString *)groupName forGroup:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 修改群公告
 
 @param bulletin 群公告
 @param groupId 群ID
 @param success 成功
 @param failure 失败
 */
+ (void)modifyGroupBulletin:(NSString *)bulletin forGroup:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;

/**
 把文本消息发送到服务器
 
 @param message 要发送的文本消息
 @param groupId 群组ID
 @param success 成功
 @param failure 失败
 */
+ (void)postTxtMessageToServiceWithMessage:(NSString *)message groupId:(NSString *)groupId success:(successBlock)success failure:(failureBlock)failure;
@end

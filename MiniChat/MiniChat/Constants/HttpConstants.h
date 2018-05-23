//
//  HttpConstants.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#ifndef HttpConstants_h
#define HttpConstants_h



//#define BaseURL         @"http://172.16.44.21:8003"

#ifdef DEBUG
//#define BaseURL   @"http://dfgimapi.xxx8.cn"

#define BaseURL   @"http://192.168.31.246:5007"


#else
#define BaseURL   @"http://imapi.xxx8.cn"
#endif


// 登录
#define LoginURL        @"api/TokenAuth/Authenticate"
// 注册
#define RegisterURL         @"api/services/app/Account/RegisterByUserName"
// 修改密码
#define ChangePasswordURL   @"api/User/Pwd"

// 获取账号信息
#define GetUserInfoURL     @"/api/services/app/User/GetRongInfo"

// 修改昵称
#define SetNickNameURL     @"api/User/SetNickName"

// 修改头像
#define SetUserPortraitURL  @"api/User/SetHeadimg"

// 修改手机号码
#define BindMobilePhoneURL  @"api/User/BindPhoneNum"

// 查询用户信息
#define SearchUserURL      @"api/services/app/User/GetFriendships"


/*************************************Friend***************************************/
// 申请好友 post
#define applyFriendURL        @"api/services/app/Friend/Apply"
// 同意好友申请 post
#define agreeFriendURL      @"api/services/app/Friend/Agree"
// 删除好友 delete
#define deleteFriendURL       @"api/services/app/Friend/Delete"
/****************************************************************************/


// 获取聊天室
#define GetChatRoomListURL  @"api/Im/ListChatroom"


// 获取用户关系列表
#define GetUserRelationshipListsURL      @"api/Im/ListFriends"


/*************************************Group***************************************/
// 创建群组
#define CreateGroupURL                   @"api/services/app/Group/Create"
// 解散群组
#define DismissGroupURL                   @"api/Im/DismissGroup"
// 获取某个群组信息
#define GetGroupInfoURL                  @"api/services/app/Group/Get"
// 获取群组列表
#define GetGroupListURL                  @"api/Im/ListGroups"
// 添加用户进群组
#define InviteIntoGroupURL               @"api/services/app/Group/AddUser"
// 离开群组
#define QuitGroupURL                     @"api/Im/QuitGroup"
// 群组踢人
#define KickGroupMemberURL               @"api/Im/KickGroup"
// 群组成员
#define GetGroupMembersURL               @"api/Im/ListGroupUsers"
//设置群组头像
#define SetGroupPortraitURL               @"api/services/app/Group/SetGroupImage"
// 修改群名称
#define ModifyGroupNameURL                 @"api/im/SetGroupName"
// 群公告
#define ModifyGroupBulletinURL                    @"api/im/SetBulletin"
// 设置群彩种
#define SetGroupLotteryURL                  @"api/services/app/Group/SetGroupLottery"
// 设置群是否可以下注
#define SetGroupCanBettingURL                @"api/services/app/Group/SetCanBetting"
/****************************************************************************/


// 发送文本消息到服务器
#define BettingMessageURL                  @"api/Lottery/BettingIm"







#endif /* HttpConstants_h */

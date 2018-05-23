//
//  CHMUserInfoManager.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/7.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMUserInfoManager.h"
#import "CHMDataBaseManager.h"

@implementation CHMUserInfoManager

+ (CHMUserInfoManager *)shareInstance {
    static CHMUserInfoManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

//通过自己的userId获取自己的用户信息
- (void)getUserInfo:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    [CHMHttpTool getUserInfoWithUserId:userId success:^(id response) {
        NSLog(@"------------%@", response);
        NSString *userName = response[@"UserName"];
        if (userName) {
            NSString *nicknName =   response[@"NickName"];
            NSString *headerImg = response[@"HeaderImage"];
            NSString *phoneNum = response[@"PhoneNum"];
            nicknName = ([nicknName isKindOfClass:[NSNull class]] || [nicknName isEqualToString:@""]) ? userName : nicknName;
            headerImg = ([headerImg isKindOfClass:[NSNull class]] || [headerImg isEqualToString:@""]) ? KDefaultPortrait : [NSString stringWithFormat:@"%@%@",BaseURL, headerImg];
            // 保存用户信息
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:KAccount];
            [[NSUserDefaults standardUserDefaults] setObject:nicknName forKey:KNickName];
            [[NSUserDefaults standardUserDefaults] setObject:headerImg forKey:KPortrait];
            [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:KPhoneNum];
            
            RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userName name:nicknName portrait:headerImg];
            completion(user);
            
        }
    } failure:^(NSError *error) {
        RCUserInfo *userInfo = [self generateDefaultUserInfo:userId];
        completion(userInfo);
    }];
}


//通过好友详细信息或好友Id获取好友信息
- (void)getFriendInfo:(NSString *)friendId completion:(void (^)(RCUserInfo *))completion {
    [CHMHttpTool searchUserInfoWithUserId:friendId success:^(id response) {
        NSLog(@"-----------%@",response);
        NSNumber *codeId = response[@"Code"][@"CodeId"];
        if (codeId.integerValue == 100) {
            NSNumber *isExist = response[@"Value"][@"Exist"];
            if (isExist.integerValue == 1) {
                
                NSString *userName = response[@"Value"][@"UserName"];
                NSString *nickName = response[@"Value"][@"NickName"];
                NSString *headimg = response[@"Value"][@"Headimg"];
                
                nickName = ([nickName isKindOfClass:[NSNull class]] ? userName : nickName);
                headimg = ([headimg isKindOfClass:[NSNull class] ] ? @"icon_person" : [NSString stringWithFormat:@"%@%@",BaseURL, headimg]);
                
                RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userName name:nickName portrait:headimg];
                completion(user);
            }
            
        }} failure:^(NSError *error) {
            RCUserInfo *userInfo = [self generateDefaultUserInfo:friendId];
            completion(userInfo);
        }];
}





- (RCUserInfo *)getFriendInfoFromDB:(NSString *)friendId {
    RCUserInfo *resultInfo;
    RCUserInfo *friend = [[CHMDataBaseManager shareManager] getFriendInfo:friendId];
    if (friend != nil) {
        resultInfo = [self getRCUserInfoByRCDUserInfo:friend];
        return resultInfo;
    }
    return nil;
}

//如有好友备注，则显示备注
- (NSArray *)getFriendInfoList:(NSArray *)friendList {
    NSMutableArray *resultList = [NSMutableArray new];
    for (RCUserInfo *user in friendList) {
        RCUserInfo *friend = [self getFriendInfoFromDB:user.userId];
        if (friend != nil) {
            [resultList addObject:friend];
        } else {
            [resultList addObject:user];
        }
    }
    NSArray *result = [[NSArray alloc] initWithArray:resultList];
    return result;
}


//设置默认的用户信息
- (RCUserInfo *)generateDefaultUserInfo:(NSString *)userId {
    RCUserInfo *defaultUserInfo = [RCUserInfo new];
    defaultUserInfo.userId = userId;
    defaultUserInfo.name = [NSString stringWithFormat:@"name%@", userId];
    defaultUserInfo.portraitUri = KDefaultPortrait;
    return defaultUserInfo;
}

//通过RCDUserInfo对象获取RCUserInfo对象
- (RCUserInfo *)getRCUserInfoByRCDUserInfo:(RCUserInfo *)friendDetails {
    RCUserInfo *friend = [RCUserInfo new];
    friend.userId = friendDetails.userId;
    friend.name = friendDetails.name;
    friend.portraitUri = friendDetails.portraitUri;
    return friend;
}

@end

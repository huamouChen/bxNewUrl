//
//  RCDSearchDataManager.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>
#import "CHMFriendModel.h"
#import "CHMGroupModel.h"
#import "CHMGroupMemberModel.h"

@implementation RCDSearchDataManager
+ (instancetype)shareInstance {
    static RCDSearchDataManager *searchDataManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        searchDataManager = [[[self class] alloc] init];
    });
    return searchDataManager;
}

- (void)searchDataWithSearchText:(NSString *)searchText
                    bySearchType:(NSInteger)searchType
                        complete:(void (^)(NSDictionary *dic, NSArray *array))result {
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!searchText.length || searchStr.length == 0) {
        return result(nil, nil);
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    if (searchType == RCDSearchFriend || searchType == RCDSearchAll) {
        NSArray *friendArray = [self searchFriendBysearchText:searchText];
        if (friendArray.count > 0) {
            [dic setObject:friendArray forKey:@"联系人"];
            [array addObject:@"联系人"];
        }
    }
    if (searchType == RCDSearchGroup || searchType == RCDSearchAll) {
        NSArray *groupArray = [self searchGroupBysearchText:searchText];
        if (groupArray.count > 0) {
            [dic setObject:groupArray forKey:@"群组"];
            [array addObject:@"群组"];
        }
    }
    if (searchType == RCDSearchChatHistory || searchType == RCDSearchAll) {
        NSArray *messsageResult = [self searchMessageBysearchText:searchText];
        if (messsageResult.count > 0) {
            [dic setObject:messsageResult forKey:@"聊天记录"];
            [array addObject:@"聊天记录"];
        }
    }
    result(dic.copy, array.copy);
}

- (NSArray *)searchFriendBysearchText:(NSString *)searchText {
    NSMutableArray *friendResults = [NSMutableArray array];
    NSArray *friendArray = [[CHMDataBaseManager shareManager] getAllFriends];
    for (CHMFriendModel *user in friendArray) {
//        if ([user.status isEqualToString:@"20"]) {
            if (user.NickName && [RCDUtilities isContains:user.NickName withString:searchText]) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_PRIVATE;
                model.targetId = user.UserName;
                model.otherInformation = user.NickName;
                model.portraitUri = user.HeaderImage;
                model.searchType = RCDSearchFriend;
                [friendResults addObject:model];
            } else if ([RCDUtilities isContains:user.NickName withString:searchText]) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_PRIVATE;
                model.targetId = user.UserName;
                model.name = user.NickName;
                model.portraitUri = user.HeaderImage;
                if (user.NickName) {
                    model.otherInformation = user.NickName;
                }
                model.searchType = RCDSearchFriend;

                [friendResults addObject:model];
            }
//        }
    }
    return friendResults;
}

- (NSArray *)searchGroupBysearchText:(NSString *)searchText {
    NSMutableArray *groupResults = [NSMutableArray array];
    NSArray *groupArray = [[CHMDataBaseManager shareManager] getAllGroup];
    for (CHMGroupModel *group in groupArray) {
        if ([RCDUtilities isContains:group.GroupName withString:searchText]) {
            RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
            model.conversationType = ConversationType_GROUP;
            model.targetId = group.GroupId;
            model.name = group.GroupName;
            model.portraitUri = group.GroupImage;
            model.searchType = RCDSearchGroup;

            [groupResults addObject:model];
            continue;
        } else {
            NSArray *groupMember = [[CHMDataBaseManager shareManager] getGroupMember:group.GroupId];
            NSString *str = nil;
            for (CHMGroupMemberModel *user in groupMember) {
                RCUserInfo *friendUser = [[CHMDataBaseManager shareManager] getFriendInfo:user.UserName];
                if (friendUser && friendUser.name.length > 0) {
                    if ([RCDUtilities isContains:friendUser.name withString:searchText]) {
                        str = [self changeString:str appendStr:friendUser.name];
                    } else if ([RCDUtilities isContains:user.NickName withString:searchText]) {
                        str = [self
                            changeString:str
                               appendStr:[NSString stringWithFormat:@"%@(%@)", friendUser.name, user.NickName]];
                    }
                } else {
                    if ([RCDUtilities isContains:user.NickName withString:searchText]) {
                        str = [self changeString:str appendStr:user.NickName];
                    }
                }
            }
            if (str.length > 0) {
                RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
                model.conversationType = ConversationType_GROUP;
                model.targetId = group.GroupId;
                model.name = group.GroupName;
                model.portraitUri = group.GroupImage;
                model.otherInformation = str;
                model.searchType = RCDSearchGroup;
                [groupResults addObject:model];
            }
        }
    }
    return groupResults;
}

- (NSArray *)searchMessageBysearchText:(NSString *)searchText {
    if (!searchText.length) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSArray *messsageResult = [[RCIMClient sharedRCIMClient]
        searchConversations:@[ @(ConversationType_GROUP), @(ConversationType_PRIVATE) ]
                messageType:@[
                    [RCTextMessage getObjectName], [RCRichContentMessage getObjectName], [RCFileMessage getObjectName]
                ]
                    keyword:searchText];

    for (RCSearchConversationResult *result in messsageResult) {
        RCDSearchResultModel *model = [[RCDSearchResultModel alloc] init];
        model.conversationType = result.conversation.conversationType;
        model.targetId = result.conversation.targetId;
        if (result.matchCount > 1) {
            model.otherInformation = [NSString stringWithFormat:@"%d条相关的记录", result.matchCount];
        } else {
            NSString *string = nil;
            model.objectName = result.conversation.objectName;
            if ([result.conversation.lastestMessage isKindOfClass:[RCRichContentMessage class]]) {
                RCRichContentMessage *rich = (RCRichContentMessage *)result.conversation.lastestMessage;
                string = rich.title;
            } else if ([result.conversation.lastestMessage isKindOfClass:[RCFileMessage class]]) {
                RCFileMessage *file = (RCFileMessage *)result.conversation.lastestMessage;
                string = file.name;
            } else {
                string = [self formatMessage:result.conversation.lastestMessage
                               withMessageId:result.conversation.lastestMessageId];
            }
            model.otherInformation = [self relaceEnterBySpace:string];
        }
        if (result.conversation.conversationType == ConversationType_PRIVATE) {
            RCUserInfo *user = [[CHMDataBaseManager shareManager] getUserByUserId:result.conversation.targetId];
            model.name = user.name;
            model.portraitUri = user.portraitUri;
        } else if (result.conversation.conversationType == ConversationType_GROUP) {
            CHMGroupModel *group = [[CHMDataBaseManager shareManager] getGroupByGroupId:result.conversation.targetId];
            model.name = group.GroupName;
            model.portraitUri = group.GroupImage;
        }
        model.searchType = RCDSearchChatHistory;
        model.count = result.matchCount;
        [array addObject:model];
    }
    return array;
}

- (NSString *)relaceEnterBySpace:(NSString *)originalString {
    NSString *string = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return string;
}

- (NSString *)formatMessage:(RCMessageContent *)messageContent withMessageId:(long)messageId {
    if ([RCIM sharedRCIM].showUnkownMessage && messageId > 0 && !messageContent) {
        return NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    } else {
        return [RCKitUtility formatMessage:messageContent];
    }
}

- (NSString *)changeString:(NSString *)str appendStr:(NSString *)appendStr {
    if (str.length > 0) {
        str = [NSString stringWithFormat:@"%@,%@", str, appendStr];
    } else {
        str = appendStr;
    }
    return str;
}
@end

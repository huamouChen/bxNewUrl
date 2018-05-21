//
//  CHMGroupTipMessage.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/15.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 测试消息的类型名
 */
#define CHMGroupTipMessageTypeIdentifier @"CHM:GtipMsg"


@interface CHMGroupTipMessage : RCMessageContent <NSCoding>


/*!
 测试消息的内容
 */
@property(nonatomic, strong) NSString *content;

/*!
 消息对应的群组ID
 */
@property(nonatomic, strong) NSString *toGroupId;

/*!
 消息的操作项
 */
@property(nonatomic, strong) NSString *opeation;



/*!
 测试消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化测试消息
 
 @param content 文本内容
 @return        测试消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content;


@end

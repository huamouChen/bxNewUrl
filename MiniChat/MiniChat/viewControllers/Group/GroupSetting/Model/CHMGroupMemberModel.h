//
//  CHMGroupMemberModel.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHMGroupMemberModel : NSObject

@property (nonatomic, copy) NSString *AddTime;
@property (nonatomic, copy) NSString *GroupId;
@property (nonatomic, copy) NSString *HeaderImage;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *NickName;
@property (nonatomic, copy) NSString *UserName;
@property (nonatomic, assign) BOOL isCheck;


- (instancetype)initWithUserName:(NSString *)userName nickName:(NSString *)nickName headerImage:(NSString *)headerImage groupId:(NSString *)groupId;
@end

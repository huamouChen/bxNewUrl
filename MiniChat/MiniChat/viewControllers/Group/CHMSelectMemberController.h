//
//  CHMSelectMemberController.h
//  MiniChat
//
//  Created by 陈华谋 on 04/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMContactsController.h"

typedef void(^DeleteMemberBlock)(NSArray *groupMemberArray);
typedef void(^AddMemberBlock)(NSMutableArray *groupMemberArray);

@interface CHMSelectMemberController : UIViewController
// 群组id
@property (nonatomic, copy) NSString *groupId;
// 群组名称
@property (nonatomic, copy) NSString *groupName;
// 是否是添加新成员
@property (nonatomic, assign) BOOL isAddMember;
// 是否是剔除成员
@property (nonatomic, assign) BOOL isDeleteMember;

// 添加成员要过滤的数组 或者 剔除成员的数组
@property (nonatomic, strong) NSMutableArray *sourceArrar;

// 剔除成员block
@property (nonatomic, copy) DeleteMemberBlock deleteMemberBlock;
// 添加成员block
@property (nonatomic, copy) AddMemberBlock addMemberBlock;

@end

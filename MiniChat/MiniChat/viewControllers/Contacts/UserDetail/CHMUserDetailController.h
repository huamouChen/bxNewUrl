//
//  CHMUserDetailController.h
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHMFriendModel, CHMGroupMemberModel;

@interface CHMUserDetailController : UITableViewController
@property (nonatomic, strong) CHMFriendModel *friendModel;
@property (nonatomic, strong) CHMGroupMemberModel *groupMemberModel;
@property (nonatomic, assign) BOOL isFriend;
@end

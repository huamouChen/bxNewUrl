//
//  CHMSelectMemberCell.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHMFriendModel, CHMGroupMemberModel;

@interface CHMSelectMemberCell : UITableViewCell
@property (nonatomic, strong) CHMFriendModel *friendModel;
@property (nonatomic, strong) CHMGroupMemberModel *groupMemberModel;
@end

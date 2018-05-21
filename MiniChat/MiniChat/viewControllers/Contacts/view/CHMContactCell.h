//
//  CHMContactCell.h
//  MiniChat
//
//  Created by 陈华谋 on 03/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHMFriendModel, CHMGroupModel;

@interface CHMContactCell : UITableViewCell
@property (nonatomic, strong) CHMFriendModel *friendModel;
@property (nonatomic, strong) CHMGroupModel *groupModel;
@end

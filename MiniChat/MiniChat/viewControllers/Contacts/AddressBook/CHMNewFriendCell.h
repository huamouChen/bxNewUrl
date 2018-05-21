//
//  CHMNewFriendCell.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/8.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHMFriendModel;

typedef void(^AcceptButtonClickBlock)(NSIndexPath *selectedIndexPath);

@interface CHMNewFriendCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) CHMFriendModel *friendModel;

@property (nonatomic, copy) AcceptButtonClickBlock acceptButtonClickBlock;

@end

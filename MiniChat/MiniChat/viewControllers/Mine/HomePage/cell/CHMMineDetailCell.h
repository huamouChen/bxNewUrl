//
//  CHMMineDetailCell.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHMFriendModel;

@interface CHMMineDetailCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *infoDict;

@property (nonatomic, strong) CHMFriendModel *friendModel;

// 是否显示向右的箭头
@property (nonatomic, assign) Boolean isHideRightArrow;


@end

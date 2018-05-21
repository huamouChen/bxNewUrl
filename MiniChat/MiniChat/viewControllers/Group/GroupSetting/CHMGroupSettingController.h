//
//  CHMGroupSettingController.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/6.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMTableViewController.h"
@class CHMGroupModel;

@interface CHMGroupSettingController : CHMTableViewController
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@end

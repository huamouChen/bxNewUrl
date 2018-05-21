//
//  CHMGroupBulletinController.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/18.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHMGroupBulletinController : UIViewController

@property (nonatomic, copy) NSString *originalGroupBulletin;

@property (nonatomic, copy) NSString *groupId;

@property (nonatomic, assign) BOOL isGroupOwner;

@end

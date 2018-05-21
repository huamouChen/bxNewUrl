//
//  CHMBettingController.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHMBettingController : UIViewController
// 目标ID，即下注的群组ID
@property (nonatomic, copy) NSString *targetId;
// 会话类型
@property (nonatomic, assign) RCConversationType conversationType;
@end

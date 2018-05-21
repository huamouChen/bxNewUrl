//
//  CHMChatRoomModel.h
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHMChatRoomModel : NSObject
@property (nonatomic, copy) NSString *GroupId;
@property (nonatomic, copy) NSString *GroupName;
@property (nonatomic, copy) NSString *GroupOwner;
@property (nonatomic, copy) NSString *GroupImage;
@property (nonatomic, copy) NSString *AddTime;
@property (nonatomic, assign) bool IsOfficial;
@property (nonatomic, assign) bool CanBetting;
@end



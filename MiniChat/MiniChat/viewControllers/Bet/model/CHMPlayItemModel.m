//
//  CHMPlayItemModel.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMPlayItemModel.h"

@implementation CHMPlayItemModel

- (instancetype)initWithPlayName:(NSString *)playName isCheck:(BOOL)isCheck {
    if (self = [super init]) {
        _playName = playName;
        _isCheck = isCheck;
    }
    return self;
}

@end

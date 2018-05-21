//
//  CHMPlayItemModel.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/4.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHMPlayItemModel : NSObject

@property (nonatomic, copy) NSString *playName;

@property (nonatomic, assign) BOOL isCheck;


- (instancetype)initWithPlayName:(NSString *)playName isCheck:(BOOL)isCheck;

@end

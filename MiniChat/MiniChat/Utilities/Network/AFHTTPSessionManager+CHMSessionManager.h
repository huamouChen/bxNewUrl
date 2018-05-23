//
//  AFHTTPSessionManager+CHMSessionManager.h
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/22.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface AFHTTPSessionManager (CHMSessionManager)

- (NSURLSessionDataTask *)chm_GET:(NSString *)URLString
                       parameters:(id)parameters
                         progress:(void (^)(NSProgress * _Nonnull))downloadProgress
                          success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                          failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull, id responseObject))failure;

- (nullable NSURLSessionDataTask *)chm_POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error, id responseObject))failure;



@end

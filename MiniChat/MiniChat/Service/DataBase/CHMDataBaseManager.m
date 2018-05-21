//
//  CHMDataBaseManager.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/7.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMDataBaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "CHMFriendModel.h"
#import "CHMGroupModel.h"
#import "CHMGroupMemberModel.h"

static NSString *const userTableName = @"USERTABLE";
static NSString *const groupTableName = @"GROUPTABLEV2";
static NSString *const friendTableName = @"FRIENDSTABLE";
static NSString *const blackTableName = @"BLACKTABLE";
static NSString *const groupMemberTableName = @"GROUPMEMBERTABLE";

@interface CHMDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation CHMDataBaseManager

+ (instancetype)shareManager {
    static CHMDataBaseManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareManager) {
            shareManager = [[CHMDataBaseManager alloc] init];
            [shareManager dbQueue];
        }
    });
    return shareManager;
}

- (void)closeDBForDisconnect {
    self.dbQueue = nil;
}

- (FMDatabaseQueue *)dbQueue {
    if ([RCIMClient sharedRCIMClient].currentUserInfo.userId == nil) {
        return nil;
    }
    if (!_dbQueue) {
        [self moveDBFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *const roungCloud = @"RongCloud";
        NSString *library = [[paths objectAtIndex:0] stringByAppendingPathComponent:roungCloud];
        NSString *dbPath = [library
                            stringByAppendingPathComponent:[NSString
                                                            stringWithFormat:@"MiniChatDB%@",
                                                            [RCIMClient sharedRCIMClient].currentUserInfo.userId]];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        if (_dbQueue) {
            [self createUserTableIfNeed];
        }
    }
    return _dbQueue;
}

- (void)moveFile:(NSString *)fileName fromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:toPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:toPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    NSString *srcPath = [fromPath stringByAppendingPathComponent:fileName];
    NSString *dstPath = [toPath stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:nil];
}

/**
 苹果审核时，要求打开itunes sharing功能的app在Document目录下不能放置用户处理不了的文件
 2.8.9之前的版本数据库保存在Document目录
 从2.8.9之前的版本升级的时候需要把数据库从Document目录移动到Library/Application Support目录
 */
- (void)moveDBFile {
    NSString *const rongIMDemoDBString = @"MiniChatDB";
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,
                                                                 YES)[0] stringByAppendingPathComponent:@"RongCloud"];
    NSArray<NSString *> *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
    [subPaths enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj hasPrefix:rongIMDemoDBString]) {
            [self moveFile:obj fromPath:documentPath toPath:libraryPath];
        }
    }];
}

#pragma mark - 建表
- (void)createUserTableIfNeed {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isTableOK:userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPTABLEV2 (id integer PRIMARY KEY autoincrement, "
            @"groupId text,name text, portraitUri text,canBetting text, "
            @"groupOwner text,addTime text, isOfficial "
            @"text, state text, bulletin text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_groupid ON GROUPTABLEV2(groupId);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDSTABLE (id integer "
            @"PRIMARY KEY autoincrement, userid "
            @"text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_friendsId ON FRIENDSTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        } else if (![self isColumnExist:@"displayName" inTable:friendTableName withDB:db]) {
            [db executeUpdate:@"ALTER TABLE FRIENDSTABLE ADD COLUMN displayName text"];
        }
        
        if (![self isTableOK:blackTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE BLACKTABLE (id integer PRIMARY "
            @"KEY autoincrement, userid text,name text, "
            @"portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_blackId ON BLACKTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![self isTableOK:groupMemberTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPMEMBERTABLE (id integer "
            @"PRIMARY KEY autoincrement, groupid text, "
            @"userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = @"CREATE unique INDEX idx_groupmemberId ON "
            @"GROUPMEMBERTABLE(groupid,userid);";
            [db executeUpdate:createIndexSQL];
        }
    }];
}



#pragma mark - 从表中获取所有好友信息

//从表中获取用户信息
- (RCUserInfo *)getUserByUserId:(NSString *)userId {
    __block RCUserInfo *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?", userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

//从表中获取所有好友信息 //RCUserInfo
- (NSArray *)getAllFriends {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDSTABLE"];
        while ([rs next]) {
            // CHMFriendModel *model;
            CHMFriendModel *model;
            model = [[CHMFriendModel alloc] init];
            model.UserName = [rs stringForColumn:@"userid"];
            model.NickName = [rs stringForColumn:@"name"];
            model.HeaderImage = [rs stringForColumn:@"portraitUri"];
            model.isCheck = NO;
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//从表中获取所有用户信息
- (NSArray *)getAllUserInfo {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

#pragma mark - 存储用户信息
// 存储用户信息
- (void)insertUserToDB:(RCUserInfo *)user {
    NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, user.userId, user.name, user.portraitUri];
    }];
}

//存储用户列表信息
- (void)insertUserListToDB:(NSMutableArray *)userList complete:(void (^)(BOOL))result {
    
    if (userList == nil || [userList count] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (RCUserInfo *user in userList) {
                NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
                [db executeUpdate:insertSql, user.userId, user.name, user.portraitUri];
            }
        }];
        result(YES);
    });
}

#pragma mark - 存储好友信息
//存储好友信息
- (void)insertFriendToDB:(RCUserInfo *)friendInfo {
    NSString *insertSql = @"REPLACE INTO FRIENDSTABLE (userid, name, "
    @"portraitUri) VALUES (?, ?, ?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, friendInfo.userId, friendInfo.name, friendInfo.portraitUri];
    }];
}
// 存储一组用户信息
- (void)insertFriendListToDB:(NSMutableArray *)FriendList complete:(void (^)(BOOL))result {
    
    if (FriendList == nil || [FriendList count] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (RCUserInfo *friendInfo in FriendList) {
                NSString *insertSql = @"REPLACE INTO FRIENDSTABLE (userid, name, "
                @"portraitUri) VALUES (?, ?, ?)";
                [db executeUpdate:insertSql, friendInfo.userId, friendInfo.name, friendInfo.portraitUri];
            }
        }];
        result(YES);
    });
}

#pragma mark - 存储群组信息
//存储群组信息
- (void)insertGroupToDB:(CHMGroupModel *)group {
    if (group == nil || [group.GroupId length] < 1)
        return;
    
    NSString *insertSql = @"REPLACE INTO GROUPTABLEV2 (groupId, "
    @"name,portraitUri,canBetting,"
    @"groupOwner,addTime,isOfficial,state, bulletin) VALUES "
    @"(?,?,?,?,?,?,?,?,?)";
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql, group.GroupId, group.GroupName, group.GroupImage, group.CanBetting, group.GroupOwner, group.AddTime,
         group.IsOfficial, group.State, group.Bulletin];
    }];
}

- (void)insertGroupsToDB:(NSMutableArray *)groupList complete:(void (^)(BOOL))result {
    if (groupList == nil || [groupList count] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (CHMGroupModel *group in groupList) {
                NSString *insertSql = @"REPLACE INTO GROUPTABLEV2 (groupId, "
                @"name,portraitUri,canBetting,"
                @"groupOwner,addTime,isOfficial,state, bulletin) VALUES "
                @"(?,?,?,?,?,?,?,?, ?)";
                [db executeUpdate:insertSql, group.GroupId, group.GroupName, group.GroupImage, group.CanBetting, group.GroupOwner, group.AddTime,
                 group.IsOfficial, group.State,group.Bulletin];
            }
        }];
        result(YES);
    });
}


//存储群组成员信息
- (void)insertGroupMemberToDB:(NSMutableArray *)groupMemberList
                      groupId:(NSString *)groupId
                     complete:(void (^)(BOOL))result {
    if (groupMemberList == nil || [groupMemberList count] < 1)
        return;
    
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", @"GROUPMEMBERTABLE", @"groupid", groupId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:deleteSql];
            for (CHMGroupMemberModel *groupMember in groupMemberList) {
                if ([groupMember.UserName isEqualToString:KAddMember] || [groupMember.UserName isEqualToString:KDeleteMember]) {
                    continue;
                }
                NSString *insertSql = @"REPLACE INTO GROUPMEMBERTABLE (groupid, userid, "
                @"name, portraitUri) VALUES (?, ?, ?, ?)";
                NSString *nickName = ([groupMember.NickName isKindOfClass:[NSNull class]] || groupMember.NickName == nil || [groupMember.NickName isEqualToString:@""]) ? groupMember.UserName : groupMember.NickName;
                [db executeUpdate:insertSql, groupId, groupMember.UserName, nickName, groupMember.HeaderImage];
            }
        }];
        result(YES);
    });
}


/**
 更新单个群成员的信息
 
 @param member 要更新的成员
 @param groupId 对应的群组
 @param result 是否成功
 */
- (void)updateMember:(RCUserInfo *)member toGroupId:(NSString *)groupId
            complete:(void (^)(BOOL))result {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//            NSString *insertSql = @"REPLACE INTO GROUPMEMBERTABLE (groupid, userid, "
//            @"name, portraitUri) VALUES (?, ?, ?, ?)";
            
            NSString *nickName = ([member.name isKindOfClass:[NSNull class]] || member.name == nil || [member.name isEqualToString:@""]) ? member.userId : member.name;
            NSString *updateSql = [NSString stringWithFormat:@"Update GROUPMEMBERTABLE set name = '%@', portraitUri = '%@' where groupid = '%@' AND userid = '%@'", nickName, member.portraitUri, groupId, member.userId];
            
            [db executeUpdate:updateSql];

//            [db executeUpdate:insertSql, groupId, member.userId, nickName, member.portraitUri];
        }
         ];
        result(YES);
//    });
}


/**
 删除群组成员
 
 @param groupMemberList 要删除群组成员数组
 @param groupId 对应的群组
 @param result 是否成功
 */
- (void)deleteGroupMemberToDB:(NSMutableArray *)groupMemberList groupId:(NSString *)groupId complete:(void (^)(BOOL))result {
    if ([groupId length] < 1)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (CHMGroupMemberModel *user in groupMemberList) {
                NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@' and %@ = '%@'", @"GROUPMEMBERTABLE", @"groupid", groupId, @"userid", user.UserName];
                [db executeUpdate:deleteSql];
            }
        }];
        result(YES);
    });
    result(NO);
}


#pragma mark - 获取群组信息
//从表中获取群组信息
- (CHMGroupModel *)getGroupByGroupId:(NSString *)groupId {
    __block CHMGroupModel *model = nil;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2 where groupId = ?", groupId];
        while ([rs next]) {
            model = [[CHMGroupModel alloc] init];
            model.GroupId = [rs stringForColumn:@"groupId"];
            model.GroupName = [rs stringForColumn:@"name"];
            model.GroupImage = [rs stringForColumn:@"portraitUri"];
            model.CanBetting = [rs stringForColumn:@"canBetting"];
            model.GroupOwner = [rs stringForColumn:@"groupOwner"];
            model.AddTime = [rs stringForColumn:@"addTime"];
            model.IsOfficial = [rs stringForColumn:@"isOfficial"];
            model.State = [rs stringForColumn:@"state"];
            model.Bulletin = [rs stringForColumn:@"bulletin"];
        }
        [rs close];
    }];
    return model;
}

//从表中获取群组成员信息
- (NSMutableArray *)getGroupMember:(NSString *)groupId {
    NSMutableArray *allUsers = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPMEMBERTABLE where groupid=? order by id", groupId];
        while ([rs next]) {
            //            RCUserInfo *model;
            CHMGroupMemberModel *model;
            model = [[CHMGroupMemberModel alloc] init];
            model.UserName = [rs stringForColumn:@"userid"];
            NSString *nickName = ([rs stringForColumn:@"name"] == nil || [[rs stringForColumn:@"name"] isEqualToString:@""]) ? model.UserName : [rs stringForColumn:@"name"];
            model.NickName = nickName;
            model.HeaderImage = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}


//删除表中的群组信息
- (void)deleteGroupToDB:(NSString *)groupId {
    if ([groupId length] < 1)
        return;
    NSString *deleteSql =
    [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", @"GROUPTABLEV2", @"groupId", groupId];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//清空表中的所有的群组信息
- (BOOL)clearGroupfromDB {
    __block BOOL result = NO;
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM GROUPTABLEV2"];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:clearSql];
    }];
    return result;
}

//从表中获取所有群组信息
- (NSMutableArray *)getAllGroup {
    NSMutableArray *allGroups = [NSMutableArray new];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2"];
        while ([rs next]) {
            CHMGroupModel *model;
            model = [[CHMGroupModel alloc] init];
            model.GroupId = [rs stringForColumn:@"groupId"];
            model.GroupName = [rs stringForColumn:@"name"];
            model.GroupImage = [rs stringForColumn:@"portraitUri"];
            model.CanBetting = [rs stringForColumn:@"canBetting"];
            model.GroupOwner = [rs stringForColumn:@"groupOwner"];
            model.AddTime = [rs stringForColumn:@"addTime"];
            model.IsOfficial = [rs stringForColumn:@"isOfficial"];
            model.State = [rs stringForColumn:@"state"];
            model.Bulletin = [rs stringForColumn:@"bulletin"];
            [allGroups addObject:model];
        }
        [rs close];
    }];
    return allGroups;
}


#pragma mark - 获取好友信息
//从表中获取某个好友的信息
- (RCUserInfo *)getFriendInfo:(NSString *)friendId {
    __block RCUserInfo *friendInfo;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDSTABLE WHERE userid=?", friendId];
        while ([rs next]) {
            friendInfo = [RCUserInfo new];
            friendInfo.userId = [rs stringForColumn:@"userid"];
            friendInfo.name = [rs stringForColumn:@"name"];
            friendInfo.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return friendInfo;
}


- (BOOL)isTableOK:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where "
                       @"type ='table' and name = ?",
                       tableName];
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count) {
            isOK = NO;
        } else {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

- (BOOL)isColumnExist:(NSString *)columnName inTable:(NSString *)tableName withDB:(FMDatabase *)db {
    BOOL isExist = NO;
    
    NSString *columnQurerySql = [NSString stringWithFormat:@"SELECT %@ from %@", columnName, tableName];
    FMResultSet *rs = [db executeQuery:columnQurerySql];
    if ([rs next]) {
        isExist = YES;
    } else {
        isExist = NO;
    }
    [rs close];
    
    return isExist;
}

@end

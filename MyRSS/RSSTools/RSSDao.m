//
//  RSSDao.m
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import "RSSDao.h"
#import "FMDB.h"
#import "NSString+Tools.h"
#import "RSSModel.h"

#define DB_NAME @"RSS.db"

@interface RSSDao ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation RSSDao

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createDB];
        [self createTable];
    }
    return self;
}

- (void)dealloc {
    [_db close];
}

- (void)createDB {
    NSString *path = [[NSString documentPath] stringByAppendingPathComponent:DB_NAME];
    NSURL *url = [NSURL fileURLWithPath:path];
    _db = [FMDatabase databaseWithURL:url];
}

- (void)createTable {
    if (![_db open]) {
        NSLog(@"db create failure");
        return;
    }
    
    NSString *sql_rss = @"create table if not exists t_rss ('ID' TEXT PRIMARY KEY,'title' TEXT, 'description' TEXT,'lastBuildDate' TEXT, 'link' TEXT)";
    BOOL b = [_db executeUpdate:sql_rss];
    
    NSString *sql_rss_item = @"create table if not exists t_item ('ID' INTEGER PRIMARY KEY AUTOINCREMENT, 'rss_id' TEXT, 'title' TEXT, 'description' TEXT,'lastBuildDate' TEXT, 'link' TEXT)";
    b = [_db executeUpdate:sql_rss_item];
    
    [_db close];
}

- (NSArray *)RSSList {
    if (![_db open]) {
        NSLog(@"db create failure");
        return @[];
    }
    NSString *sql_rss_list = @"select * from 't_rss'";
    FMResultSet *result = [_db executeQuery:sql_rss_list];
    NSMutableArray *arr = [NSMutableArray array];
    while ([result next]) {
        RSSModel *rss = [[RSSModel alloc] init];
        rss.ID = [result stringForColumn:@"ID"];
        rss.title = [result stringForColumn:@"title"];
        rss.descriptionStr = [result stringForColumn:@"description"];
        rss.lastBuildDate = [result stringForColumn:@"lastBuildDate"];
        rss.link = [result stringForColumn:@"link"];
        [arr addObject:rss];
    }
    [_db close];
    return arr;
}

- (RSSModel *)itemListWithRSS:(RSSModel *)model {
    if (![_db open]) {
        NSLog(@"db create failure");
        return model;
    }
    NSString *sql_rss_list = @"select * from 't_item' where rss_id=?";
    FMResultSet *result = [_db executeQuery:sql_rss_list withArgumentsInArray:@[model.ID]];
    NSMutableArray *arr = [NSMutableArray array];
    while ([result next]) {
        RSSItem *item = [[RSSItem alloc] init];
        item.ID = [result intForColumn:@"ID"];
        item.rss_id = [result stringForColumn:@"rss_id"];
        item.title = [result stringForColumn:@"title"];
        item.descriptionStr = [result stringForColumn:@"description"];
        item.lastBuildDate = [result stringForColumn:@"lastBuildDate"];
        item.link = [result stringForColumn:@"link"];
        [arr addObject:item];
    }
    model.item = arr;
    [_db close];
    return model;
}

- (BOOL)insertRSS:(RSSModel *)model {
    if (![_db open]) {
        NSLog(@"db create failure");
        return NO;
    }
    
    //1.开启事务
    BOOL b = [_db beginTransaction];
    BOOL success = NO;
    @try {
        //2.在事务中执行任务
        BOOL b = [_db executeUpdate:@"insert into t_rss(ID, title, description, lastBuildDate, link) values(:ID, :title, :description, :lastBuildDate, :link)" withParameterDictionary:@{@"ID": model.ID ?: @"",                                                                     @"title": model.title ?: @"", @"description": model.descriptionStr ?: @"", @"lastBuildDate": model.lastBuildDate ?: @"", @"link": model.link ?: @""}];
        __weak typeof(self) weakSelf = self;
        for (RSSItem * _Nonnull obj in model.item) {
            BOOL a = [weakSelf.db executeUpdate:@"insert into t_item(rss_id, title, description, lastBuildDate, link) values(:rss_id, :title, :description, :lastBuildDate, :link)" withParameterDictionary:@{@"rss_id": obj.rss_id ?: @"", @"title": obj.title ?: @"", @"description": obj.descriptionStr ?: @"", @"lastBuildDate": obj.lastBuildDate ?: @"", @"link": obj.link ?: @""}];
        }
    }
    @catch(NSException *exception) {
        //3.在事务中执行任务失败，退回开启事务之前的状态
        [_db rollback];
    }
    @finally {
        //4. 在事务中执行任务成功之后
        success = YES;
        [_db commit];
    }
    [_db close];
    return success;
}

- (BOOL)deleteRSS:(RSSModel *)model {
    if (![_db open]) {
        NSLog(@"db create failure");
        return NO;
    }
    
    //1.开启事务
    [_db beginTransaction];
    BOOL success = NO;
    @try {
        //2.在事务中执行任务
        [_db executeUpdate:@"delete from 't_item' where rss_id = ?" withArgumentsInArray:@[model.ID]];
        [_db executeUpdate:@"delete from 't_item' where ID = ?" withArgumentsInArray:@[model.ID]];
    }
    @catch(NSException *exception) {
        //3.在事务中执行任务失败，退回开启事务之前的状态
        [_db rollback];
    }
    @finally {
        //4. 在事务中执行任务成功之后
        success = YES;
        [_db commit];
    }
    [_db close];
    return success;
}

+ (NSArray<RSSModel *> *)RSSList {
    return [[RSSDao shareInstance] RSSList];
}
+ (RSSModel *)itemListWithRSS:(RSSModel *)model {
    return [[RSSDao shareInstance]itemListWithRSS:model];
}
+ (BOOL)insertRSS:(RSSModel *)model {
    return [[RSSDao shareInstance] insertRSS:model];
}
+ (BOOL)deleteRSS:(RSSModel *)model {
    return [[RSSDao shareInstance] deleteRSS:model];
}

@end

//
//  RSS.m
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import "RSS.h"
#import "AFNetworking.h"
#import "NSString+Tools.h"
#import "RSSDao.h"
#import "RSSModel.h"
#import "GDataXMLNode.h"

@interface RSS ()

+ (instancetype)shareInstance;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSArray *localRSSList;

@end

@implementation RSS

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/atom+xml", @"application/rss+xml", nil];
    }
    return self;
}

- (NSArray *)localRSSList {
    if (_localRSSList) {
        _localRSSList = [RSSDao RSSList];
    }
    return _localRSSList;
}

+ (void)addRSSWithURL:(NSString *)urlStr handler:(void(^)(RSSModel *rss))handler {
    NSString *key = [urlStr MD5];
    __block RSSModel *model = nil;
    [[RSS shareInstance].localRSSList enumerateObjectsUsingBlock:^(RSSModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([key isEqualToString:obj.ID]) {
            model = obj;
            *stop = YES;
        }
    }];
    if (model) {
        if (handler) handler(model);
        return;
    }
    [RSS loadRSSWithURL:urlStr handler:handler];
}

+ (void)loadRSSWithURL:(NSString *)urlStr handler:(void(^)(RSSModel *rss))handler{
    NSString *key = [urlStr MD5];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[RSS shareInstance].manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:responseObject error:nil];
        GDataXMLElement *rss = [xml.rootElement elementsForName:@"channel"].firstObject;
        RSSModel *model = [[RSSModel alloc] init];
        model.ID = key;
        if (rss) {
            model.title = [[rss elementsForName:@"title"].firstObject stringValue];
            model.descriptionStr = [[rss elementsForName:@"description"].firstObject stringValue];
            model.lastBuildDate = [[rss elementsForName:@"lastBuildDate"].firstObject stringValue];
            model.link = urlStr;
            NSMutableArray *items = [NSMutableArray array];
            for (GDataXMLElement *element in [rss elementsForName:@"item"]) {
                RSSItem *item = [[RSSItem alloc] init];
                item.rss_id = key;
                item.title = [[element elementsForName:@"title"].firstObject stringValue];
                item.descriptionStr = [[element elementsForName:@"description"].firstObject stringValue];
                item.lastBuildDate = [[element elementsForName:@"pubDate"].firstObject stringValue];
                item.link = [[element elementsForName:@"link"].firstObject stringValue];
                [items addObject:item];
            }
            model.item = items;
        } else {
            model.title = [[xml.rootElement elementsForName:@"title"].firstObject stringValue];
            model.descriptionStr = [[xml.rootElement elementsForName:@"subtitle"].firstObject stringValue];
            model.lastBuildDate = [[xml.rootElement elementsForName:@"updated"].firstObject stringValue];
            model.link = urlStr;
            NSMutableArray *items = [NSMutableArray array];
            for (GDataXMLElement *element in [xml.rootElement elementsForName:@"entry"]) {
                RSSItem *item = [[RSSItem alloc] init];
                item.rss_id = key;
                item.title = [[element elementsForName:@"title"].firstObject stringValue];
                item.descriptionStr = [[element elementsForName:@"content"].firstObject stringValue];
                item.lastBuildDate = [[element elementsForName:@"updated"].firstObject stringValue];
                item.link = [[[element elementsForName:@"link"].firstObject attributeForName:@"href"] stringValue];
                [items addObject:item];
            }
            model.item = items;
        }
        [RSSDao deleteRSS:model];
        [RSSDao insertRSS:model];
        if (handler) handler(model);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (handler) handler(nil);
    }];
}

+ (NSArray<RSSModel *> *)localRSSList {
    NSArray *mArr = [RSSDao RSSList];
    [RSS shareInstance].localRSSList = mArr;
    return mArr;
}

+ (void)refreshRSSData:(RSSModel *)model handler:(void(^)(void))handler {
    [RSS loadRSSWithURL:model.link handler:^(RSSModel *rss) {
        model.item = rss.item;
        model.lastBuildDate = rss.lastBuildDate;
        model.title = rss.title;
        if (handler) handler();
    }];
}

+ (RSSModel *)modelListWithRSS:(RSSModel *)mod {
    return [RSSDao itemListWithRSS:mod];
}

+ (BOOL)removeRSS:(RSSModel *)mod {
    return [RSSDao deleteRSS:mod];
}

+ (BOOL)removeAllRSS {
    return [RSSDao deleteAllRSS];
}


@end

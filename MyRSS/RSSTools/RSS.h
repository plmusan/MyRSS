//
//  RSS.h
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSModel;

@interface RSS : NSObject

+ (void)addRSSWithURL:(NSString *)urlStr handler:(void(^)(RSSModel *rss))handler;
+ (NSArray<RSSModel *> *)localRSSList;

+ (void)refreshRSSData:(RSSModel *)model handler:(void(^)(void))handler;

+ (RSSModel *)modelListWithRSS:(RSSModel *)mod;

+ (BOOL)removeRSS:(RSSModel *)mod;

@end

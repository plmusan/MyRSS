//
//  RSSDao.h
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSModel;

@interface RSSDao : NSObject

+ (NSArray<RSSModel *> *)RSSList;
+ (RSSModel *)itemListWithRSS:(RSSModel *)model;
+ (BOOL)insertRSS:(RSSModel *)model;
+ (BOOL)deleteRSS:(RSSModel *)model;

+ (BOOL)deleteAllRSS;

@end

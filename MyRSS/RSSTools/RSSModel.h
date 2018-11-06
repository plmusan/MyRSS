//
//  RSSModel.h
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *rss_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *descriptionStr;
@property (nonatomic, copy) NSString *lastBuildDate;
@property (nonatomic, copy) NSString *link;

@end

@interface RSSModel : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *descriptionStr;
@property (nonatomic, copy) NSString *lastBuildDate;
@property (nonatomic, copy) NSString *link;

@property (nonatomic, copy) NSArray<RSSItem *> *item;

@end


//
//  NSString+Tools.h
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tools)

- (NSString *)MD5;

+ (NSString *)documentPath;

@end

NS_ASSUME_NONNULL_END

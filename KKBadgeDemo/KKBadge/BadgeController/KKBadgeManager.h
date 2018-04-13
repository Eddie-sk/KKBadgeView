//
//  KKBadgeManager.h
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/13.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KKBadgeInfo.h"
#import "KKBadgeModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface KKBadgeManager : NSObject

#pragma mark -Initialize

+ (KKBadgeManager *)shareManager;

#pragma mark - Observer

- (void)observeWithInfo:(nullable KKBadgeInfo *)info;

- (void)unobserveWithInfo:(nullable KKBadgeInfo *)info;

- (void)unobserveWithInfos:(nullable NSHashTable<KKBadgeInfo *> *)infos;

#pragma mark - Operation

- (void)refreshBadgeWithInfos:(NSHashTable<KKBadgeInfo *> *)infos;

- (void)setBadgeForKeyPath:(NSString *)keyPath;

- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count;

- (void)clearBadgeForKeyPath:(NSString *)keyPath;

- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced;

- (BOOL)isNeedShowForKeyPath:(NSString *)keyPath;

- (NSUInteger)countForKeyPath:(NSString *)keyPath;

@end
NS_ASSUME_NONNULL_END

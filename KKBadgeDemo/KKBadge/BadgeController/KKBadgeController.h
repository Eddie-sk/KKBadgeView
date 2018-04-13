//
//  KKBadgeController.h
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBadgeView.h"

NS_ASSUME_NONNULL_BEGIN //Non null区域设置:此区域内的所有指针都被假定为nonull（不可为空），我们只需指定那些nullable（可以为空）的指针，为苹果的人性化设置点赞👍

typedef void (^KKBadgeNotificationBlock)(id _Nullable observer, NSDictionary<NSString *, id> *info);

@interface KKBadgeController : NSObject

/**
    The observer notified on badge changed. Specified on initialization
 */
@property (nullable, nonatomic, weak, readonly) id observer;

#pragma mark - Initialized

+ (instancetype)controllerWithObserver:(nullable id)observer;

- (instancetype)initWithObserver:(nullable id)observer NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;


#pragma mark - Observer

- (void)obsevePath:(NSString *)keyPath block:(KKBadgeNotificationBlock)block;

- (void)observePath:(NSString *)keyPath badgeView:(nullable id<KKBadgeView>)badgeView block:(nullable KKBadgeNotificationBlock)block;

- (void)observePaths:(NSArray<NSString *> *)keyPaths block:(KKBadgeNotificationBlock)block;

#pragma mark - Unobserve

- (void)unobservePath:(NSString *)keyPath;

- (void)unobserveAll;


#pragma mark - Operation

- (void)refreshBadgeView;

+ (void)setBadgeForKeyPath:(NSString *)keyPath;
+ (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count;

+ (void)clearBadgeForKeyPath:(NSString *)keyPath;
+ (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced;

+ (BOOL)statusForKeyPath:(NSString *)keyPath;

+ (NSUInteger)countForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END

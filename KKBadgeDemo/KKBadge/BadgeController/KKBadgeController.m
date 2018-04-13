//
//  KKBadgeController.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "KKBadgeController.h"
#import "KKBadgeInfo.h"
#import "KKBadgeManager.h"
#import <pthread/pthread.h>

@implementation KKBadgeController {
    NSHashTable<KKBadgeInfo *> *_infos;
    pthread_mutex_t _lock;
}

#pragma mark - Lifecycle

- (instancetype)initWithObserver:(id)observer {
    self = [super init];
    if (self) {
        _observer = observer;
        
        _infos = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality) capacity:0];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

+ (instancetype)controllerWithObserver:(id)observer {
    return [[self alloc] initWithObserver:observer];
}

- (void)dealloc {
    [self unobserveAll];
    
    pthread_mutex_destroy(&_lock);
}

#pragma mark - Observer

- (void)observePath:(NSString *)keyPath block:(KKBadgeNotificationBlock)block {
    NSAssert(0 != keyPath.length && NULL != block, @"missing required paramenters: keyPath:%@ block:%p", keyPath, block);
    
    if (0 != keyPath.length && NULL != block) {
        return;
    }
    
    KKBadgeInfo *info = [[KKBadgeInfo alloc] initWithController:self keyPath:keyPath block:block];
    
    [self _observerWithInfo:info];
}

- (void)observePath:(NSString *)keyPath badgeView:(id<KKBadgeView>)badgeView block:(nullable KKBadgeNotificationBlock)block {
    
    NSAssert(0 != keyPath.length, @"missing required paramenters: keyPath:%@", keyPath);
    
    if (keyPath.length == 0) {
        return;
    }
    
    KKBadgeInfo *info = [[KKBadgeInfo alloc] initWithController:self keyPath:keyPath badgeView:badgeView block:block];
    
    [self _observerWithInfo:info];
}

- (void)observePaths:(NSArray<NSString *> *)keyPaths block:(KKBadgeNotificationBlock)block {
    NSAssert(0 != keyPaths.count && NULL != block, @"missing required parameters: keyPaths:%@ block:%p", keyPaths, block);
    
    if (0 == keyPaths.count || NULL == block) return;
    
    for (NSString *keyPath in keyPaths) {
        [self observePath:keyPath block:block];
    }
}

- (void)unobservePath:(NSString *)keyPath {
    KKBadgeInfo *info = [[KKBadgeInfo alloc] initWithController:self keyPath:keyPath];
    [self _unobserveWithInfo:info];
}

- (void)unobserveAll {
    [self _unobserveAll];
}

#pragma mark - Utilities

- (void)_observerWithInfo:(KKBadgeInfo *)info {
    pthread_mutex_lock(&_lock);
    
    KKBadgeInfo *existingInfo = [_infos member:info];
    
    if (existingInfo) {
        pthread_mutex_unlock(&_lock);
        return;
    }
    
    [_infos addObject:info];
    
    pthread_mutex_unlock(&_lock);
    
    [[KKBadgeManager shareManager] observeWithInfo:info];
}

- (void)_unobserveWithInfo:(KKBadgeInfo *)info {
    pthread_mutex_lock(&_lock);
    
    KKBadgeInfo *registerInfo = [_infos member:info];
    
    if (registerInfo) {
        [_infos removeObject:registerInfo];
    }
    
    pthread_mutex_unlock(&_lock);
    [[KKBadgeManager shareManager] unobserveWithInfo:info];
}

- (void)_unobserveAll {
    pthread_mutex_lock(&_lock);
    NSHashTable *infos = [_infos copy];
    
    [_infos removeAllObjects];
    pthread_mutex_unlock(&_lock);
    
    [[KKBadgeManager shareManager] unobserveWithInfos:infos];
}

#pragma mark - Properties

- (NSString *)debugDescription
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
    [s appendFormat:@" observer:<%@:%p>", NSStringFromClass([_observer class]), _observer];
    
    pthread_mutex_lock(&_lock);
    
    if (0 != _infos.count) {
        [s appendString:@"\n  "];
    }
    
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
    
    for (KKBadgeInfo *info in _infos) {
        [infoDescriptions addObject:info.debugDescription];
    }
    
    [s appendFormat:@"-> %@", infoDescriptions];
    
    pthread_mutex_unlock(&_lock);
    
    [s appendString:@">"];
    
    return s;
}

#pragma mark - Operation

- (void)refreshBadgeView {
    [[KKBadgeManager shareManager] refreshBadgeWithInfos:_infos];
}

+ (void)setBadgeForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return;
    
    [[KKBadgeManager shareManager] setBadgeForKeyPath:keyPath];
}

+ (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count
{
    if (![keyPath length]) return;
    
    [[KKBadgeManager shareManager] setBadgeForKeyPath:keyPath count:count];
}

+ (void)clearBadgeForKeyPath:(NSString *)keyPath {
    [self clearBadgeForKeyPath:keyPath forced:NO];
}

+ (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced
{
    if (![keyPath length]) return;
    
    [[KKBadgeManager shareManager] clearBadgeForKeyPath:keyPath forced:forced];
}

+ (BOOL)statusForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return NO;
    
    return [[KKBadgeManager shareManager] isNeedShowForKeyPath:keyPath];
}

+ (NSUInteger)countForKeyPath:(NSString *)keyPath
{
    if (![keyPath length]) return 0;
    
    return [[KKBadgeManager shareManager] countForKeyPath:keyPath];
}

@end

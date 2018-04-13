//
//  KKBadgeManager.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/13.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "KKBadgeManager.h"
#import <pthread/pthread.h>

#import "NSString+KKBadge.h"

#ifndef dispatch_queue_async_kkbadge
#define dispatch_queue_async_kkbadge(queue, block)\
        if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) { \
            block(); \
        } else { \
            dispatch_async(queue, block); \
        }
#endif

#ifndef dispatch_main_async_kkbadge
#define dispatch_main_async_kkbadge(block) dispatch_queue_async_kkbadge(dispatch_get_main_queue(),block)
#endif

@implementation KKBadgeManager {
    NSMutableDictionary<NSString *, NSMutableSet<KKBadgeInfo *> *> *_objectInfosMap;
    
    KKBadgeModel *_root;
    
    pthread_mutex_t _lock;
    
    dispatch_queue_t _badgeQueue;
    
}

#pragma mark - Lifecycle

+ (KKBadgeManager *)shareManager {
    static KKBadgeManager *_badgeMgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _badgeMgr = [KKBadgeManager new];
    });
    return _badgeMgr;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_lock, &attr);
        pthread_mutexattr_destroy(&attr);
        
        _objectInfosMap = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        _badgeQueue = dispatch_queue_create("com.kook.badge.queue", DISPATCH_QUEUE_CONCURRENT);
        [self setupRootBadge];
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

#pragma mark - Observe

- (void)observeWithInfo:(nullable KKBadgeInfo *)info {
    if (!info) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    
    NSString *keyPath = info.keyPath;
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];
    
    if (!infos) {
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:keyPath];
    }
    
    [infos addObject:info];
    
    pthread_mutex_unlock(&_lock);
    
    id<KKBadge> badge = [self badgeForKeyPath:keyPath];
    if (badge && [badge needShow]) {
        [self statusChangedForBadges:@[badge]];
    }
}

- (void)unobserveWithInfo:(nullable KKBadgeInfo *)info {
    if (!info) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    
    NSString *keyPath = info.keyPath;
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:keyPath];
    
    KKBadgeInfo *registeredInfo = [infos member:info];
    
    id<KKBadgeView> badgeView = registeredInfo.badgeView;
    
    if (registeredInfo) {
        [infos removeObject:registeredInfo];
        
        if (infos.count == 0) {
            [_objectInfosMap removeObjectForKey:keyPath];
        }
    }
    
    pthread_mutex_unlock(&_lock);
    
    if (badgeView && [badgeView conformsToProtocol:@protocol(KKBadgeView)]) {
        dispatch_main_async_kkbadge(^{
            [badgeView hideBadge];
        });
    }
}

- (void)unobserveWithInfos:(NSHashTable<KKBadgeInfo *> *)infos {
    if (infos.count == 0) {
        return;
    }
    
    for (KKBadgeInfo *info in infos) {
        [self unobserveWithInfo:info];
    }
}

#pragma mark - Setup Root Badge

- (void)setupRootBadge {
    NSString *badgeFile = [NSString badgeJSONPath];
    
    NSDictionary *badgeFileDic = [NSDictionary dictionaryWithContentsOfFile:badgeFile];
    
    NSDictionary *badgeDic = badgeFileDic ? :@{KKBadgeNameKey : KKBadgeRootPath,
                                               KKBadgePathKey : KKBadgeRootPath,
                                               KKBadgeCountKey : @(0),
                                               KKBadgeShowKey : @(YES)};
    _root = [KKBadgeModel initWithDictionary:badgeDic];
    if (!badgeFileDic) {
        [self saveBadgeInfo];
    }
}

- (void)saveBadgeInfo {
    [[_root dictionaryFormat] writeToFile:[NSString badgeJSONPath] atomically:YES];
}

#pragma mark - Set Badge

- (void)setBadgeForKeyPath:(NSString *)keyPath {
    [self setBadgeForKeyPath:keyPath count:0];
}

- (void)setBadgeForKeyPath:(NSString *)keyPath count:(NSUInteger)count {
    if (!keyPath || keyPath.length == 0) {
        return;
    }
    
    NSArray *keyPathArray = [keyPath componentsSeparatedByString:@"."];
    
    NSMutableArray *notifyBadges = [NSMutableArray array];
    
    pthread_mutex_lock(&_lock);
    
    id<KKBadge> bParent = _root;
    
    for (NSString *name in keyPathArray) {
        if ([name isEqualToString:KKBadgeRootPath]) {
            continue;
        }
        
        id<KKBadge> objLeaf = nil;
        for (id<KKBadge> leaf in bParent.children) {
            if ([leaf.name isEqualToString:name]) {
                objLeaf = leaf;
                break;
            }
        }
        NSString *namePath = [NSString stringWithFormat:@".%@",name];
        NSString *subKeyPath = [bParent.keyPath stringByAppendingString:namePath];
        
        if (!objLeaf) {
            BOOL set = [name isEqualToString:[keyPathArray lastObject]];
            objLeaf = [KKBadgeModel initWithDictionary:@{KKBadgeNameKey : name,
                                                         KKBadgePathKey : subKeyPath,
                                                         KKBadgeCountKey : @(0),
                                                         KKBadgeShowKey : @(set)}];
            objLeaf.parent = bParent;
            [bParent addChild:objLeaf];
        }
        bParent = objLeaf;
        if ([subKeyPath isEqualToString:keyPath]) {
            objLeaf.needShow = YES;
            objLeaf.count = count;
        }
        [notifyBadges addObject:objLeaf];
    }
    [self saveBadgeInfo];
    pthread_mutex_unlock(&_lock);
    [self statusChangedForBadges:[notifyBadges mutableCopy]];
}

#pragma mark - Clear Badge

- (void)clearBadgeForKeyPath:(NSString *)keyPath {
    [self clearBadgeForKeyPath:keyPath forced:NO];
}

- (void)clearBadgeForKeyPath:(NSString *)keyPath forced:(BOOL)forced {
    if (!keyPath || keyPath.length == 0) {
        return;
    }
    
    NSArray *keyPathArray = [keyPath componentsSeparatedByString:@"."];
    
    NSMutableArray *notifyBadges = [NSMutableArray array];
    
    pthread_mutex_lock(&_lock);
    
    id<KKBadge> bParent = _root;
    
    for (NSString *name in keyPathArray) {
        if ([name isEqualToString:KKBadgeRootPath]) {
            continue;
        }
        
        id<KKBadge> objLeaf = nil;
        
        for (id<KKBadge> leaf in bParent.children) {
            if ([leaf.name isEqualToString:name]) {
                objLeaf = leaf;
                bParent = objLeaf;
                break;
            }
        }
        if (!objLeaf) {
            pthread_mutex_unlock(&_lock);return;
        }
        
        if ([name isEqualToString:[keyPathArray lastObject]]) {
            objLeaf.needShow = NO;
            if ([objLeaf.children count] == 0 || forced) {
                if ([objLeaf.children count] && forced) {
                    NSArray *bs = [objLeaf.allLinkedChildren mutableCopy];
                    [notifyBadges addObjectsFromArray:bs];
                    [objLeaf clearAllChildren];
                }
                objLeaf.count = 0;
                [objLeaf removeFromParent];
            }
            [self saveBadgeInfo];
        }
        [notifyBadges addObject:objLeaf];
    }
    pthread_mutex_unlock(&_lock);
    [self statusChangedForBadges:[notifyBadges mutableCopy]];
}

#pragma mark - Status Changed

- (void)statusChangedForBadges:(NSArray<id<KKBadge> > *)badges {
    if (!badges || [badges count] == 0) {
        return;
    }
    
    for (id<KKBadge> badge in badges) {
        NSString *path = badge.keyPath;
        if ([path isEqualToString:KKBadgeRootPath]) continue;
        
        pthread_mutex_lock(&_lock);
        NSMutableSet *infos = [[_objectInfosMap objectForKey:path] copy];
        pthread_mutex_unlock(&_lock);
        
        [infos enumerateObjectsUsingBlock:^(KKBadgeInfo *bInfo, BOOL * _Nonnull stop) {
            id<KKBadgeView> badgeView = bInfo.badgeView;
            if (badgeView && [badgeView conformsToProtocol:@protocol(KKBadgeView)]) {
                NSUInteger c = badge.count;
                dispatch_main_async_kkbadge(^{
                    if (c > 0) {
                        [badgeView showBadgeWithValue:c];
                    } else if (badge.needShow) {
                        [badgeView showBadge];;
                    } else {
                        [badgeView hideBadge];
                    }
                });
            }
            if (bInfo.block) {
                id observer = bInfo.controller.observer;
                bInfo.block(observer, @{ KKBadgePathKey  :   badge.keyPath,
                                         KKBadgeShowKey  : @(badge.needShow),
                                         KKBadgeCountKey : @(badge.count) });
            }
        }];
        
    }
}
#pragma mark - Refresh Badge
- (void)refreshBadgeWithInfos:(NSHashTable<KKBadgeInfo *> *)infos
{
    if (0 == infos.count) return;
    
    for (KKBadgeInfo *bInfo in infos) {
        id<KKBadge> badge         = [self badgeForKeyPath:bInfo.keyPath];
        id<KKBadgeView> badgeView = bInfo.badgeView;
        if (badgeView && [badgeView conformsToProtocol:@protocol(KKBadgeView)]) {
            NSUInteger c = badge.count;
            dispatch_main_async_kkbadge(^{
                if (c > 0) {
                    [badgeView showBadgeWithValue:c];
                } else if (badge.needShow) {
                    [badgeView showBadge];
                } else {
                    [badgeView hideBadge];
                }
            });
        }
    }
}

#pragma mark - Badge Status
- (BOOL)statusForKeyPath:(NSString *)keyPath {
    return [[self badgeForKeyPath:keyPath] needShow];
}

- (NSUInteger)countForKeyPath:(NSString *)keyPath
{
    id<KKBadge> badge = [self badgeForKeyPath:keyPath];
    return badge ? badge.count : 0;
}

#pragma mark - Helper
- (id<KKBadge>)badgeForKeyPath:(NSString *)keyPath
{
    NSArray *kPaths   = [keyPath componentsSeparatedByString:@"."];
    id<KKBadge> badge = nil;
    
    pthread_mutex_lock(&_lock);
    
    id<KKBadge> bParent = _root;
    
    for (NSString *name in kPaths) {
        if ([name isEqualToString:KKBadgeRootPath]) {
            continue;
        }
        id<KKBadge> objFind = nil;
        for (id<KKBadge> obj in bParent.children) {
            if ([obj.name isEqualToString:name]) {
                objFind = obj; bParent = objFind;
                break;
            }
        }
        
        if (!objFind) {
            pthread_mutex_unlock(&_lock);
            return nil;
        }
        
        badge = objFind;
    }
    
    pthread_mutex_unlock(&_lock);
    
    return badge;
}

@end

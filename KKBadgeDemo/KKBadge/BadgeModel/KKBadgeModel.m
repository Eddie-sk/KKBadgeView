//
//  KKBadgeModel.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "KKBadgeModel.h"
#import <pthread/pthread.h>


NSString * const KKBadgeRootPath    = @"ccwork";

NSString * const KKBadgeNameKey     = @"KKBadgeNameKey";
NSString * const KKBadgePathKey     = @"KKBadgePathKey";
NSString * const KKBadgeChildrenKey = @"KKBadgeChildrenKey";
NSString * const KKBadgeShowKey     = @"KKBadgeShowKey";
NSString * const KKBadgeCountKey    = @"KKBadgeCountKey";

@interface KKBadgeModel(){
    pthread_mutex_t _lock;
}

@property (nonatomic, copy, readwrite) NSString *name;

@property (nonatomic, copy, readwrite) NSString *keyPath;

@property (nonatomic, strong, readwrite) NSMutableArray<id<KKBadge>> *children;

@end

@implementation KKBadgeModel

@synthesize count = _count, allLinkedChildren = _allLinkedChildren, parent = _parent, children = _children, needShow = _needShow;

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.name = dic[KKBadgeNameKey];
        self.keyPath = dic[KKBadgePathKey];
        
        self.needShow = [dic[KKBadgeShowKey] boolValue];
        self.count = [dic[KKBadgeCountKey] integerValue];
        self.children = [[NSMutableArray alloc] init];
        
        NSArray *children = dic[KKBadgeChildrenKey];
        if (children) {
            [children enumerateObjectsUsingBlock:^(NSDictionary *child, NSUInteger idx, BOOL * _Nonnull stop) {
                KKBadgeModel *obj = [KKBadgeModel initWithDictionary:child];
                if (obj) {
                    obj.parent = self;
                    [self.children addObject:obj];
                }
            }];
        }
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    KKBadgeModel *model = [[[self class] alloc] init];
    model.name = self.name;
    model.keyPath = self.keyPath;
    model.count = self.count;
    model.needShow = self.needShow;
    model.parent = self.parent;
    model.children = self.children;
    return model;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (NSString *)debugDescription {
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass(self.class), self, _keyPath];
    [s appendFormat:@" count:%@",@(_count).stringValue];
    [s appendFormat:@" needShow:%@",@(_needShow).stringValue];
    
    if (NULL != _name) {
        [s appendFormat:@" name:%@", _name];
    }
    
    if (NULL != _parent) {
        [s appendFormat:@" parent.path:%@",_parent.keyPath];
    }
    
    if ([_children count]) {
        NSMutableArray *subPaths = [NSMutableArray array];
        for (KKBadgeModel *child in _children) {
            [subPaths addObject:child.keyPath];
        }
        [s appendFormat:@" children.path:%@", subPaths];
    }
    [s appendString:@">"];
    return s;
}

#pragma mark - Badge

+ (nonnull id<KKBadge>)initWithDictionary:(nonnull NSDictionary *)dic {
    if (![dic count]) {
        return  nil;
    }
    return [[KKBadgeModel alloc] initWithDictionary:dic];
}

- (void)addChild:(nonnull id<KKBadge>)child {
    pthread_mutex_lock(&_lock);
    
    if (child) {
        [self.children addObject:child];
    }
    pthread_mutex_unlock(&_lock);
}

- (void)clearAllChildren {
    pthread_mutex_lock(&_lock);
    
    NSArray *children = [self.children copy];
    
    [self.children removeAllObjects];
    
    pthread_mutex_unlock(&_lock);
    
    for (id<KKBadge> child in children) {
        child.needShow = NO;
        child.count = 0;
        [child clearAllChildren];
    }
}

- (nonnull NSDictionary *)dictionaryFormat {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    if (self.name) dic[KKBadgeNameKey] = self.name;
    if (self.keyPath) dic[KKBadgePathKey] = self.keyPath;
    if (self.count) dic[KKBadgeCountKey] = @(self.count);
    if (self.needShow) dic[KKBadgeShowKey] = @(self.needShow);
    
    if ([self.children count]) {
        NSMutableArray *children = [NSMutableArray new];
        dic[KKBadgeChildrenKey] = children;
        [self.children enumerateObjectsUsingBlock:^(id<KKBadge>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [children addObject:[obj dictionaryFormat]];
        }];
    }
    return dic;
}

- (void)removeChild:(nonnull id<KKBadge>)child {
    
    pthread_mutex_lock(&_lock);
    
    if ([self.children containsObject:child]) {
        [self.children removeObject:child];
        if (![self.children count]) {
            self.needShow = NO;
            self.count = 0;
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeFromParent {
    if (self.parent) {
        [self.parent removeChild:self];
        self.parent = nil;
    }
}


#pragma mark - Getter/Setter

- (BOOL)needShow {
    if ([self.children count]) {
        for (id<KKBadge> badge in self.children) {
            if (badge.needShow) {
                return YES;
            }
        }
        return NO;
    }
    return _needShow;
}

- (NSUInteger)count {
    if ([self.children count]) {
        __block NSUInteger subCount = 0;
        
        [self.children enumerateObjectsUsingBlock:^(id<KKBadge>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            subCount += obj.count;
        }];
        _count = subCount;
    }
    return _count;
}

- (NSMutableArray<id<KKBadge>> *)allLinkedChildren {
    NSMutableArray *links = [self.children mutableCopy];
    
    if ([self.children count]) {
        [self.children enumerateObjectsUsingBlock:^(id<KKBadge>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [links addObjectsFromArray:obj.allLinkedChildren];
        }];
    }
    return links;
}

@end

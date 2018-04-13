//
//  KKBadgeInfo.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "KKBadgeInfo.h"

@implementation KKBadgeInfo

#pragma mark - Initialize

- (instancetype)initWithController:(KKBadgeController *)controller keyPath:(NSString *)keyPath {
    return [self initWithController:controller keyPath:keyPath  block:nil];
}

- (instancetype)initWithController:(KKBadgeController *)controller keyPath:(NSString *)keyPath block:(KKBadgeNotificationBlock)block {
    return [self initWithController:controller keyPath:keyPath badgeView:nil block:block];
}

- (instancetype)initWithController:(KKBadgeController *)controller keyPath:(NSString *)keyPath badgeView:(id<KKBadgeView>)badgeView block:(KKBadgeNotificationBlock)block {
    self = [super init];
    
    if (self) {
        _controller = controller;
        _badgeView = badgeView;
        _block = block;
        _keyPath = keyPath;
    }
    
    return self;
}

#pragma mark - Properties

- (NSUInteger)hash {
    return [_keyPath hash] ^ [_controller hash] ^ [_badgeView hash];
}

- (BOOL)isEqual:(id)object {
    if (nil == object) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    KKBadgeInfo *badgeObj = (KKBadgeInfo *)object;
    
    BOOL isEqualPath = [_keyPath isEqualToString:badgeObj.keyPath];
    
    BOOL isEqualController = (_controller == badgeObj.controller);
    
    BOOL isEqualView = (_badgeView ==badgeObj.badgeView);
    
    return isEqualPath && isEqualController && isEqualView;
    
}

- (NSString *)debugDescription {
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass(self.class), self, _keyPath];
    
    if (NULL != _block) {
        [s appendFormat:@" block:%p", _block];
    }
    
    [s appendString:@">"];
    return s;
}

@end

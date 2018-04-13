//
//  KKBadgeInfo.h
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KKBadgeController.h"

NS_ASSUME_NONNULL_BEGIN


@interface KKBadgeInfo : NSObject

@property (nonatomic, copy, readonly) NSString *keyPath;

@property (nonatomic, weak, readonly) KKBadgeController *controller;

@property (nonatomic, copy, readonly) KKBadgeNotificationBlock block;

@property (nonatomic, strong, readonly) id<KKBadgeView> badgeView;

//TODO:keyPath to many controllers
- (instancetype)initWithController:(KKBadgeController *)controller
                           keyPath:(NSString *)keyPath;

- (instancetype)initWithController:(KKBadgeController *)controller
                           keyPath:(NSString *)keyPath
                             block:(nullable KKBadgeNotificationBlock)block;

- (instancetype)initWithController:(KKBadgeController *)controller
                           keyPath:(NSString *)keyPath
                         badgeView:(nullable id<KKBadgeView>)badgeView
                             block:(KKBadgeNotificationBlock)block;


@end

NS_ASSUME_NONNULL_END

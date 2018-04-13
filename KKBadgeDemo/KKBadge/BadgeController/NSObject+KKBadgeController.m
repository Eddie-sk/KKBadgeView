//
//  NSObject+KKBadgeController.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/13.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "NSObject+KKBadgeController.h"
#import <objc/runtime.h>

static void *NSObjectBadgeControllerKey = &NSObjectBadgeControllerKey;

@implementation NSObject (KKBadgeController)

- (KKBadgeController *)badgeController {
    id controller = objc_getAssociatedObject(self, NSObjectBadgeControllerKey);
    if (!controller) {
        controller = [KKBadgeController controllerWithObserver:self];
        self.badgeController = controller;
    }
    return controller;
}

- (void)setBadgeController:(KKBadgeController *)badgeController {
    objc_setAssociatedObject(self, NSObjectBadgeControllerKey, badgeController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

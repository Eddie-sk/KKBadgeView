//
//  UITabBarItem+KKBadge.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "UITabBarItem+KKBadge.h"
#import <objc/runtime.h>
#import "UIView+KKBadge.h"

@implementation UITabBarItem (KKBadge)

#pragma mark - KKBadgeView

- (void)showBadge {
    [[self badgeView] showBadge];
}

- (void)hideBadge {
    [[self badgeView] hideBadge];
}

#pragma mark - Private Methods

- (UIView *)badgeView {
    UIView *bottomView = [self valueForKeyPath:@"_view"];
    UIView *parentView = nil;
    if (bottomView) {
        parentView = [self find:bottomView firstSubviewWithClass:NSClassFromString(@"UITabBarSwappableImageView")];
    }
    return parentView;
}

- (UIView *)find:(UIView *)view firstSubviewWithClass:(Class)cls
{
    __block UIView *targetView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(UIView     *subview,
                                                NSUInteger idx,
                                                BOOL       *stop) {
        if ([subview isKindOfClass:cls]) {
            targetView = subview; *stop = YES;
        }
    }];
    return targetView;
}

#pragma mark - Getter/Setter

- (UILabel *)badge {
    return [self badgeView].badge;
}

- (void)setBadge:(UILabel *)badge {
    [[self badgeView] setBadge:badge];
}

- (UIFont *)badgeFont {
    return [self badgeView].badgeFont;
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    [[self badgeView] setBadgeFont:badgeFont];
}

- (UIColor *)badgeColor {
    return [[self badgeView] badgeColor];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    [[self badgeView] setBadgeColor:badgeColor];
}

- (UIColor *)badgeTextColor {
    return [[self badgeView] badgeTextColor];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [[self badgeView] setBadgeTextColor:badgeTextColor];
}

- (CGFloat)badgeRadius {
    return [[self badgeView] badgeRadius];
}

- (void)setBadgeRadius:(CGFloat)badgeRadius {
    [[self badgeView] setBadgeRadius:badgeRadius];
}

- (CGPoint)badgeOffset {
    return [[self badgeView] badgeOffset];
}

- (void)setBadgeOffset:(CGPoint)badgeOffset {
    [[self badgeView] setBadgeOffset:badgeOffset];
}

@end

//
//  UIBarButtonItem+KKBadge.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "UIBarButtonItem+KKBadge.h"
#import <objc/runtime.h>
#import "UIView+KKBadge.h"

@implementation UIBarButtonItem (KKBadge)

#pragma mark - KKBadgeView
- (void)showBadge {
    [[self badgeView] showBadge];
}
- (void)hideBadge {
    [[self badgeView] hideBadge];
}

- (void)showBadgeWithValue:(NSUInteger)value {
    [[self badgeView] showBadgeWithValue:value];
}

#pragma mark - private method
- (UIView *)badgeView {
    return [self valueForKeyPath:@"_view"];
}

#pragma mark - setter/getter
- (UILabel *)badge {
    return [self badgeView].badge;
}

- (void)setBadge:(UILabel *)label {
    [[self badgeView] setBadge:label];
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

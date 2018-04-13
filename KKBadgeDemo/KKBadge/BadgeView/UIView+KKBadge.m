//
//  UIView+KKBadge.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "UIView+KKBadge.h"
#import <objc/runtime.h>

#define kKKBadgeDefaultFont                ([UIFont boldSystemFontOfSize:9])
#define kKKBadgeDefaultMaximumBadgeNumber  99

static const CGFloat kKKBadgeDefaultRadius = 3.f;

@implementation UIView (KKBadge)

#pragma mark - KKBadgeView

- (void)showBadge {
    if (self.customView) {
        self.customView.hidden = NO;
        self.badge.hidden = YES;
    } else {
        CGFloat width = kKKBadgeDefaultRadius * 2;
        CGRect rect = CGRectMake(CGRectGetWidth(self.frame), -width, width, width);
        
        self.badge.frame = rect;
        self.badge.text = @"";
        self.badge.hidden = NO;
        self.badge.layer.cornerRadius = CGRectGetWidth(self.badge.frame) / 2.0;
        
        CGFloat offsetX = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
        self.badge.center = CGPointMake(offsetX, self.badgeOffset.y);
        
    }
}

- (void)showBadgeWithValue:(NSUInteger)value {
    self.customView.hidden = YES;
    
    self.badge.hidden = (value == 0);
    
    self.badge.font = self.badgeFont;
    self.badge.text = (value > kKKBadgeDefaultMaximumBadgeNumber ?
                       [NSString stringWithFormat:@"%@+", @(kKKBadgeDefaultMaximumBadgeNumber)] :
                       @(value).stringValue);
    
    [self adjustLabelWidth:self.badge];
    
    CGRect frame = self.badge.frame;
    frame.size.width += 4;
    frame.size.height += 4;
    
    if (CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
        frame.size.width = CGRectGetHeight(frame);
    }
    
    self.badge.frame = frame;
    CGFloat offsetX = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
    
    self.badge.center = CGPointMake(offsetX, self.badgeOffset.y);
    self.badge.layer.cornerRadius = CGRectGetWidth(self.badge.frame) / 2.0f;
}

- (void)hideBadge {
    if (self.customView) {
        self.customView.hidden = YES;
    }
    self.badge.hidden = YES;
}

#pragma mark - Private Methods

- (void)adjustLabelWidth:(UILabel *)label {
    [label setNumberOfLines:0];
    
    NSString *s = label.text;
    UIFont *font = label.font;
    CGSize size = CGSizeMake(320, 2000);
    
    CGSize labelSize = CGSizeZero;
    if (![s respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        labelSize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    } else {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        labelSize = [s boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style} context:nil].size;
    }
    
    CGRect frame = label.frame;
    frame.size = CGSizeMake(ceilf(labelSize.width), ceilf(labelSize.height));
    [label setFrame:frame];
}

#pragma mark - Getter/Setter

- (UILabel *)badge {
    UILabel *bLabel = objc_getAssociatedObject(self, _cmd);
    if (!bLabel) {
        CGFloat width = kKKBadgeDefaultRadius * 2;
        
        CGRect rect = CGRectMake(CGRectGetWidth(self.frame), -width, width, width);
        bLabel = [[UILabel alloc] initWithFrame:rect];
        bLabel.textAlignment = NSTextAlignmentCenter;
        bLabel.backgroundColor = [UIColor redColor];
        bLabel.textColor = [UIColor whiteColor];
        bLabel.text = @"";
        CGFloat offsetX = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
        bLabel.center = CGPointMake(offsetX, self.badgeOffset.y);
        
        bLabel.layer.cornerRadius = kKKBadgeDefaultRadius;
        bLabel.layer.masksToBounds = YES;
        bLabel.hidden = YES;
        
        objc_setAssociatedObject(self, _cmd, bLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:bLabel];
        [self bringSubviewToFront:bLabel];
        
    }
    return bLabel;
}

- (void)setBadge:(UILabel *)badge {
    objc_setAssociatedObject(self, @selector(badge), badge, OBJC_ASSOCIATION_RETAIN);
}

- (UIFont *)badgeFont {
    return objc_getAssociatedObject(self, _cmd) ?: kKKBadgeDefaultFont;
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    objc_setAssociatedObject(self, @selector(badgeFont), badgeFont, OBJC_ASSOCIATION_RETAIN);
    self.badge.font = badgeFont;
}

- (UIColor *)badgeColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    objc_setAssociatedObject(self, @selector(badgeColor), badgeColor, OBJC_ASSOCIATION_RETAIN);
    self.badge.backgroundColor = badgeColor;
}

- (UIColor *)badgeTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    objc_setAssociatedObject(self, @selector(badgeTextColor), badgeTextColor, OBJC_ASSOCIATION_RETAIN);
    self.badge.textColor = badgeTextColor;
}

- (CGFloat)badgeRadius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setBadgeRadius:(CGFloat)badgeRadius {
    objc_setAssociatedObject(self, @selector(badgeRadius), @(badgeRadius), OBJC_ASSOCIATION_RETAIN);
}

- (CGPoint)badgeOffset {
    NSValue *offset = objc_getAssociatedObject(self, _cmd);
    if (!offset) {
        return CGPointZero;
    }
    return [offset CGPointValue];
}

- (void)setBadgeOffset:(CGPoint)badgeOffset {
    objc_setAssociatedObject(self, @selector(badgeOffset), [NSValue valueWithCGPoint:badgeOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)badgeImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBadgeImage:(UIImage *)badgeImage {
    self.customView = [[UIImageView alloc] initWithImage:badgeImage];
    objc_setAssociatedObject(self, @selector(badgeImage), badgeImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)customView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomView:(UIView *)customView {
    if (self.customView == customView) {
        return;
    }
    
    if (self.customView) {
        [self.customView removeFromSuperview];
    }
    
    if (customView) {
        [self addSubview:customView];
    }
    
    objc_setAssociatedObject(self, @selector(customView), customView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.customView) {
        CGRect bound = customView.bounds;
        bound.origin.x = CGRectGetWidth(self.frame);
        bound.origin.y = -bound.size.height;
        
        self.customView.frame = bound;
        CGFloat offsetX = CGRectGetWidth(self.frame) + 2 + self.badgeOffset.x;
        
        self.customView.center = CGPointMake(offsetX, self.badgeOffset.y);
    }
}

@end

//
//  KKBadgeView.h
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 priority: number > custom view > red dot
 */

@protocol KKBadgeView <NSObject>

@required

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIFont *badgeFont;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) UIColor *badgeTextColor;
@property (nonatomic, assign) CGFloat badgeRadius;
@property (nonatomic, assign) CGPoint badgeOffset;

- (void)showBadge;

- (void)hideBadge;

- (void)showBadgeWithValue:(NSUInteger)value;

@optional

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIImage *badgeImage;

@end

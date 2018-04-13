//
//  KKBadge.h
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol KKBadge <NSObject, NSCopying>

@required

@property (nonatomic, copy, readonly) NSString *name;       // e.g. 'badge'
@property (nonatomic, copy, readonly) NSString *keyPath;    // e.g. 'ccwork.msg.single'

/**
 1. non-leaf node, sum of children
 2. terminal node: return  'count'
 3. setter valid for terminal node
 */
@property (nonatomic, assign) NSUInteger count;

/**
 1. non-leaf node: has any children?
 2. terminal node: return 'needShow'
 */
@property (nonatomic, assign) BOOL needShow;

//immediated children of current badge
@property (nonatomic, strong, readonly) NSMutableArray<id<KKBadge>> *children;

//all linked children, including children's children
@property (nonatomic, strong, readonly) NSMutableArray<id<KKBadge>> *allLinkedChildren;

@property (nonatomic, weak) id<KKBadge> parent;

//regist nodes in terms or key path
+ (id<KKBadge>)initWithDictionary:(NSDictionary *)dic;


/**
 convert id <KKBadge> object to dictionary,
 useful for, e.g. Data Persistence / Archive
 */
- (NSDictionary *)dictionaryFormat;


- (void)addChild:(id<KKBadge>)child;        //add leaf

- (void)removeChild:(id<KKBadge>)child;     //cut leaf

- (void)clearAllChildren;

- (void)removeFromParent;

@end


NS_ASSUME_NONNULL_END



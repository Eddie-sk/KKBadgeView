//
//  NSString+KKBadge.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/13.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "NSString+KKBadge.h"

@implementation NSString (KKBadge)

+ (NSString *)badgeFilePath {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *badgePath = [libraryPath stringByAppendingPathComponent:@"KKBadgeFile"];
    [self createDirectoryAtPath:badgePath];
    
    return badgePath;
}

+ (NSString *)badgeJSONPath {
    
    NSString *filePath = [self badgeFilePath];
    return [filePath stringByAppendingPathComponent:@"badge.json"];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path {
    NSAssert(path,@"");
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return YES;
    }
    return NO;
}

@end

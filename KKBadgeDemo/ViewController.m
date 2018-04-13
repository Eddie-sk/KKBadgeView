//
//  ViewController.m
//  KKBadgeDemo
//
//  Created by sunkai on 2018/4/12.
//  Copyright © 2018年 CCWork. All rights reserved.
//

#import "ViewController.h"
#import "KKBadgeKit.h"

NSString * const DEMO_PARENT_PATH = @"ccwork.badge";
NSString * const DEMO_CHILD_PATH1 = @"ccwork.badge.test1";
NSString * const DEMO_CHILD_PATH2 = @"ccwork.badge.test2";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *rootLabel;
@property (weak, nonatomic) IBOutlet UILabel *badge1;
@property (weak, nonatomic) IBOutlet UILabel *badge2;
@property (weak, nonatomic) IBOutlet UIButton *badge3;
@property (weak, nonatomic) IBOutlet UIButton *badge4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.badgeController observePath:DEMO_PARENT_PATH badgeView:self.rootLabel block:^(id  _Nullable observer, NSDictionary<NSString *,id> * _Nonnull info) {
        NSLog(@"%@ => %@",DEMO_PARENT_PATH, info);
    }];
    
    self.rootLabel.text = DEMO_PARENT_PATH;
    
    [self.badgeController observePath:DEMO_CHILD_PATH1 badgeView:self.badge1 block:^(id  _Nullable observer, NSDictionary<NSString *,id> * _Nonnull info) {
        NSLog(@"%@ => %@",DEMO_CHILD_PATH1, info);
    }];
    self.badge1.text = DEMO_CHILD_PATH1;
    
    [self.badgeController observePath:DEMO_CHILD_PATH2 badgeView:self.badge2 block:^(id  _Nullable observer, NSDictionary<NSString *,id> * _Nonnull info) {
        NSLog(@"%@ => %@",DEMO_CHILD_PATH2, info);
    }];
    self.badge2.text = DEMO_CHILD_PATH2;
    
    [self.badgeController observePath:DEMO_CHILD_PATH1 badgeView:self.badge3 block:^(id  _Nullable observer, NSDictionary<NSString *,id> * _Nonnull info) {
        NSLog(@"%@ => %@",DEMO_CHILD_PATH1, info);
    }];
    [self.badgeController observePath:DEMO_CHILD_PATH1 badgeView:self.badge4 block:^(id  _Nullable observer, NSDictionary<NSString *,id> * _Nonnull info) {
        NSLog(@"%@ => %@",DEMO_CHILD_PATH1, info);
    }];
    [self.badge3 setTitle:DEMO_CHILD_PATH1 forState:UIControlStateNormal];
    
    self.badge4.badgeColor = [UIColor lightGrayColor];
//    [KKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1];
//    [KKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH2 count:1];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cleanBadge:(id)sender {
    [KKBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH1];
}
- (IBAction)setBadge1Action:(id)sender {
    [KKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1 count:1];
}

@end

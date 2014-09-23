//
//  AppDelegate.h
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP (AppDelegate *)[[UIApplication sharedApplication] delegate]
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)validateAccount;

@end

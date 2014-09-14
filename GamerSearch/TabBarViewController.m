//
//  TabBarViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "TabBarViewController.h"

#import <FontAwesomeKit.h>

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    float iconSize = 34.0f;

    FAKFontAwesome *icons[] = {
        [FAKFontAwesome gamepadIconWithSize:iconSize],
        [FAKFontAwesome   usersIconWithSize:iconSize],
        [FAKFontAwesome    userIconWithSize:iconSize],
        [FAKFontAwesome     cogIconWithSize:iconSize]
    };
    
    NSString *tabTitle[] = {
        @"マップ",
        @"フォローリスト",
        @"プロフィール",
        @"設定"
    };
    
    for ( int i = 0; i < self.viewControllers.count; ++i ) {
        UIViewController *vc = self.viewControllers[i];
        UIImage *iconImage = [icons[i] imageWithSize:CGSizeMake(iconSize, iconSize)];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:tabTitle[i] image:iconImage tag:i];
    }
    
}

@end

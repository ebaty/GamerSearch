//
//  TabBarViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "TabBarViewController.h"
#import "NADView.h"

#import <FontAwesomeKit.h>

@interface TabBarViewController () <NADViewDelegate>

@property (nonatomic, retain) NADView * nadView;

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
    
    // 広告の挿入枠を確保
    CGRect frame = self.tabBar.frame;
    frame.origin.y = frame.origin.y - 50;
    frame.size.height = 50 + 50;
    self.tabBar.frame = frame;
    self.view.bounds = self.tabBar.bounds;
    
    // 広告の初期化・表示
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, 50, UIScreen.mainScreen.bounds.size.width, 50)];
    [self.nadView setNendID:@"5c5797e2cd1da1a1300c72ad36dcd4030ab064a5" spotID:@"238099"];
    self.nadView.delegate = self;
    self.nadView.backgroundColor = UIColor.lightGrayColor;
    [self.tabBar addSubview:self.nadView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    for(UIView *view in self.view.subviews)
    {
        CGRect _rect = view.frame;
        if(![view isKindOfClass:[UITabBar class]])
        {
            _rect.size.height = _rect.size.height - 50;
            view.frame = _rect;
        }
    }
}

@end

//
//  IntroViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/24.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "IntroViewController.h"

#define kMyColor UIColor.blackColor
#import <EAIntroView.h>
#import <FAKFontAwesome.h>
@interface IntroViewController () <EAIntroDelegate>

@property (nonatomic) EAIntroView *introView;

@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createAndShowIntroView];
}

- (void)createAndShowIntroView {
    CGFloat iconFloat = 100.0f;
    CGSize  iconSize  = CGSizeMake(iconFloat, iconFloat);
    FAKFontAwesome *icon[] = {
        [FAKFontAwesome angellistIconWithSize:iconFloat],
        [FAKFontAwesome gamepadIconWithSize:iconFloat],
        [FAKFontAwesome mapMarkerIconWithSize:iconFloat],
        [FAKFontAwesome binocularsIconWithSize:iconFloat],
        [FAKFontAwesome commentOIconWithSize:iconFloat]
    };
    
    // コンセプト
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"ゲーム好き同士の交流のきっかけに";
    page1.desc = @"このアプリのコンセプトは、ゲームセンターのユーザーのコミュニケーションツールとなることです。";
    
    // マップ
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"今ゲームセンターにいる人がわかる！";
    page2.desc = @"アプリをインストールしているユーザーは、登録されているゲームセンターに近づくと自動でチェックインします。";
    
    // マップの追加
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"ゲームセンターの追加";
    page3.desc = @"マップ上を長押しするとマーカーを立てることができます。よく行くゲームセンターが無い場合はすぐ追加しましょう。";

    // フォロー
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"ユーザーのチェックインを通知！";
    page4.desc = @"ユーザー詳細画面からフォローしたユーザーのチェックインをプッシュ通知します。";
    
    // フィードバック
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"フィードバックをください！";
    page5.desc = @"このアプリはまだまだ未完成です。「こういう機能がほしい！」「この機能はいらない…」といった意見を常に募集しています。（フィードバックの送信は設定から）";
    
    // オレンジの背景
    UIImage *orangeImage = [self getOrangeImage];

    NSArray *pages = @[page1, page2, page3, page4, page5];
    for ( int i = 0; i < pages.count; ++i ) {
        EAIntroPage *page = pages[i];
        page.titleColor = kMyColor;
        page.titlePositionY = 200.0f;
        
        page.descColor  = kMyColor;
        page.descPositionY = 180.0f;
        
        page.bgImage = orangeImage;
        
        // アイコンの設定
        [icon[i] addAttribute:NSForegroundColorAttributeName value:kMyColor];
        page.titleIconView = [[UIImageView alloc] initWithImage:[icon[i] imageWithSize:iconSize]];
        page.titleIconPositionY = 100.0f;
    }
    
    _introView = [[EAIntroView alloc] initWithFrame:UIScreen.mainScreen.bounds andPages:pages];
    _introView.delegate = self;
    _introView.pageControl.currentPageIndicatorTintColor = kMyColor;
    [_introView.skipButton setTitleColor:kMyColor forState:UIControlStateNormal];

    [_introView showInView:self.view animateDuration:0.0f];
}

- (UIImage *)getOrangeImage {
    UIView *orangeView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    orangeView.backgroundColor = [UIColor colorWithRed:1.0f green:0.588f blue:0.173f alpha:1.0f];

    UIImage* image;
    
    UIGraphicsBeginImageContext(orangeView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [orangeView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - EAIntroView delegate method.
- (void)introDidFinish:(EAIntroView *)introView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

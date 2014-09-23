//
//  IntroViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/24.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "IntroViewController.h"

#import <EAIntroView.h>
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
    // コンセプト
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"page1";
    page1.desc = @"1";
    
    // マップ
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"page2";
    page2.desc = @"2";
    
    // マップの追加
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"page3";
    page2.desc = @"3";
    
    // ユーザー詳細
    NSArray *pages = @[page1, page2, page3];
    _introView = [[EAIntroView alloc] initWithFrame:UIScreen.mainScreen.bounds andPages:pages];
    _introView.delegate = self;

    [_introView showInView:self.view animateDuration:0.0f];
}

#pragma mark - EAIntroView delegate method.
- (void)introDidFinish:(EAIntroView *)introView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

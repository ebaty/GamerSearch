//
//  SettingTextViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/23.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "SettingTextViewController.h"

@interface SettingTextViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SettingTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *textDictionary =
    @{
      @"利用規約"          :@"Terms_Of_Service",
      @"プライバシーポリシー":@"Privacy_Policy"
    };
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:textDictionary[self.title] ofType:@"txt"];
    NSError *error;
    _textView.text = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if ( error ) DDLogError(@"%@", error);
}


@end

//
//  TextViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/23.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TextViewController

- (void)viewDidLoad {
    _titleLabel.text = self.title;
    
    NSDictionary *queryTextDictionary =
    @{
      @"利用規約"          :@"Terms_Of_Service",
      @"プライバシーポリシー":@"Privacy_Policy"
    };
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:queryTextDictionary[self.title] ofType:@"txt"];
    NSError *error;
    _textView.text = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if ( error ) DDLogError(@"%@", error);
}

- (IBAction)didPushCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

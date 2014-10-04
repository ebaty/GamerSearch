//
//  FeedbackViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/25.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomSpace;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeBarButton;

@end

@implementation FeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    self.navigationItem.rightBarButtonItem = _sendBarButton;
    _sendBarButton.enabled = NO;
}

#pragma mark - UIEvent method.
- (IBAction)didPushSendButton:(id)sender {
    PFObject *feedback = [PFObject objectWithClassName:@"Feedback"];

    NSData *textData = [_textView.text dataUsingEncoding:NSUTF8StringEncoding];
    PFFile *textFile = [PFFile fileWithName:@"feedback.txt" data:textData];
    
    feedback[@"username"] = [PFUser currentUser][@"username"];
    feedback[@"feedback"] = textFile;
    
    [SVProgressHUD showWithStatus:@"フィードバックを送信しています..." maskType:SVProgressHUDMaskTypeBlack];
    [feedback saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            [SVProgressHUD showSuccessWithStatus:@"フィードバックの送信ありがとうございます！"];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [SVProgressHUD showErrorWithStatus:@"フィードバックの送信に失敗しました"];
        }
    }];
}

- (IBAction)didPushCloseButton:(id)sender {
    [self.view closeKeyboard];
}

#pragma mark - UITextView delegate methods.
- (void)textViewDidBeginEditing:(UITextView *)textView {
    _textViewBottomSpace.constant = 168;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.16f animations:^{
        [self.view layoutIfNeeded];
    }];
    self.navigationItem.rightBarButtonItem = _closeBarButton;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _textViewBottomSpace.constant = 8;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.16f animations:^{
        [self.view layoutIfNeeded];
    }];
    self.navigationItem.rightBarButtonItem = _sendBarButton;
}

- (void)textViewDidChange:(UITextView *)textView {
    _sendBarButton.enabled = textView.text.length > 0;
}
@end

//
//  ProfileTableViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/20.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *psnTextField;
@property (weak, nonatomic) IBOutlet UITextField *xboxLiveTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UISwitch *fightGamerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *musicGamerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *actionGamerSwitch;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@end

@implementation ProfileTableViewController

#pragma mark - Init methods.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _userImageView.layer.borderColor = UIColor.lightGrayColor.CGColor;

    // キーボードのNotificationを設定
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
    
    [self setUpParameterFromPFUser];
}

- (void)setUpParameterFromPFUser {
    PFUser *user = [PFUser currentUser];
    
    _userNameTextField.text = user[@"username"];
    _psnTextField.text      = user[@"psn_id"];
    _xboxLiveTextField.text = user[@"xbox_live"];
    _twitterTextField.text  = user[@"twitter_id"];

    _fightGamerSwitch.on  = [user[@"fightGamer"] boolValue];
    _musicGamerSwitch.on  = [user[@"musicGamer"] boolValue];
    _actionGamerSwitch.on = [user[@"actionGamer"] boolValue];
    
    PFFile *userImageFile = user[@"userImage"];
    PFFile *textFile = user[@"comment"];
    
    if ( userImageFile && ![userImageFile isEqual:[NSNull null]] ) {
        [_userImageView showIndicator];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [_userImageView dismissIndicator];
            if ( !error ) _userImageView.image = [UIImage imageWithData:data];
        }];
    }

    if ( textFile ) {
        [_textView showIndicator];
        [textFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [_textView dismissIndicator];
            if ( !error ) _textView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }];
    }

}

#pragma mark - UIEvent methods.
- (IBAction)didPushedChangeImageButton:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.bk_didFinishPickingMediaBlock =
    ^(UIImagePickerController *picker, NSDictionary *params) {
        _userImageView.image = (UIImage *)[params objectForKey:UIImagePickerControllerEditedImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    picker.bk_didCancelBlock =
    ^(UIImagePickerController *picker) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)didPushedSaveBarButton:(id)sender {
    // 画像とテキストをNSData化
    NSData *imageData = UIImageJPEGRepresentation(_userImageView.image, 0.0f);
    NSData *textData = [_textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // PFFile化
    PFFile *userImageFile = imageData ? [PFFile fileWithName:@"userImage.jpg" data:imageData] : nil;
    PFFile *textFile = [PFFile fileWithName:@"comment.txt" data:textData];
    
    // JSON化
    NSDictionary *params =
    @{
      @"username"   : _userNameTextField.text,
      @"psn_id"     : _psnTextField.text,
      @"xbox_live"  : _xboxLiveTextField.text,
      @"twitter_id" : _twitterTextField.text,
      @"userImage"  : userImageFile ? userImageFile : [NSNull null],
      @"fightGamer" : @(_fightGamerSwitch.on),
      @"musicGamer" : @(_musicGamerSwitch.on),
      @"actionGamer": @(_actionGamerSwitch.on),
      @"comment"    : textFile
    };
    
    [PFController postUserProfile:params progress:YES handler:nil];
}

- (IBAction)didPushedDoneBarButton:(id)sender {
    [self resignFirstResponderForSubview:self.view];
}

- (void)resignFirstResponderForSubview:(UIView *)view {
    for ( id v in view.subviews ) {
        if ( [v isKindOfClass:[UIView class]] )
            [self resignFirstResponderForSubview:v];
        
        if ( [v isKindOfClass:[UITextField class]] )
            [v resignFirstResponder];
        
        if ( [v isKindOfClass:[UITextView class]] )
            [v resignFirstResponder];
    }
}

#pragma mark - Notification methods.
- (void)keyboardWillShow:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = _doneBarButtonItem;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
}

#pragma mark - UITextField delegate methods.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return range.location <= 30;
}

#pragma mark - UITextView delegate methods.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return range.location <= 500;
}

@end

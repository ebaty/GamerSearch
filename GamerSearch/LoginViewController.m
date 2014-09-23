//
//  LoginViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/23.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "LoginViewController.h"
#import "TextViewController.h"
#import "AppDelegate.h"

#import <FAKFontAwesome.h>

#define kIconSize 30.0f
@interface LoginViewController () {
    FAKFontAwesome *squareIcon;
    FAKFontAwesome *checkSquareIcon;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondPasswordTextField;

@property (weak, nonatomic) IBOutlet UIImageView *FirstCheckBoxImageView;
@property (weak, nonatomic) IBOutlet UIImageView *SecondCheckBoxImageView;

@property (nonatomic) BOOL firstCheck;
@property (nonatomic) BOOL secondCheck;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    squareIcon = [FAKFontAwesome squareOIconWithSize:kIconSize];
    checkSquareIcon = [FAKFontAwesome checkSquareOIconWithSize:kIconSize];
    
    self.firstCheck  = NO;
    self.secondCheck = NO;
}

- (void)registerAccount {
    PFUser *newUser = [PFUser user];
    newUser.username = _userNameTextField.text;
    newUser.password = _firstPasswordTextField.text;
    
    [SVProgressHUD showWithStatus:@"ユーザーを登録しています..." maskType:SVProgressHUDMaskTypeBlack];
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            [SVProgressHUD showSuccessWithStatus:@"ユーザー登録が完了しました"];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] validateAccount];
        }else {
            if ( error.code == 202 ) {
                [SVProgressHUD showErrorWithStatus:@"既に使用されているユーザー名です。違うユーザー名を使用してください。"];
            }
            DDLogError(@"%@", error);
        }
    }];
}

- (void)loginAccount:(NSString *)userName password:(NSString *)password {
    [SVProgressHUD showWithStatus:@"サーバーと通信しています..." maskType:SVProgressHUDMaskTypeBlack];
    [PFUser logInWithUsernameInBackground:userName password:password block:^(PFUser *user, NSError *error) {
        if ( !error ) {
            [SVProgressHUD showSuccessWithStatus:@"ログインに成功しました"];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] validateAccount];
        }else {
            if ( error.code == 101 ) {
                [SVProgressHUD showErrorWithStatus:@"ユーザー名またはパスワードが間違っています。"];
            }
            DDLogError(@"%@", error);
        }
    }];
}

#pragma mark - Setter methods.
- (void)setFirstCheck:(BOOL)firstCheck {
    _firstCheck = firstCheck;
    
    if ( _firstCheck ) {
        _FirstCheckBoxImageView.image =
            [checkSquareIcon imageWithSize:CGSizeMake(kIconSize, kIconSize)];
    }else {
        _FirstCheckBoxImageView.image =
            [squareIcon imageWithSize:CGSizeMake(kIconSize, kIconSize)];
    }
}

- (void)setSecondCheck:(BOOL)secondCheck {
    _secondCheck = secondCheck;
    
    if ( _secondCheck ) {
        _SecondCheckBoxImageView.image =
            [checkSquareIcon imageWithSize:CGSizeMake(kIconSize, kIconSize)];
    }else {
        _SecondCheckBoxImageView.image =
            [squareIcon imageWithSize:CGSizeMake(kIconSize, kIconSize)];
    }
}

#pragma mark - UIEvent methods.
- (IBAction)didTapFirstImageView:(id)sender {
    self.firstCheck = !_firstCheck;
}

- (IBAction)didTapSecondImageView:(id)sender {
    self.secondCheck = !_secondCheck;
}

- (IBAction)didTapView:(id)sender {
    [self.view closeKeyboard];
}

- (IBAction)didPushRegisterAccountButton:(id)sender {
    UIAlertView *alertView = [UIAlertView new];
    alertView.title = @"登録内容に不備があります";
    alertView.cancelButtonIndex = 0;
    [alertView addButtonWithTitle:@"確認"];
    
    NSString *message = @"";
    if ( _userNameTextField.text.length == 0 ) {
        message = [message stringByAppendingString:@"ユーザー名を入力してください\n"];
    }
    if ( _firstPasswordTextField.text.length == 0 || _secondPasswordTextField.text.length == 0 ) {
        message = [message stringByAppendingString:@"パスワードを入力してください\n"];
    }
    else if ( ![_firstPasswordTextField.text isEqualToString:_secondPasswordTextField.text] ) {
        message = [message stringByAppendingString:@"再入力されたパスワードが正しくありません\n"];
    }
    if ( !_firstCheck || !_secondCheck ) {
        message = [message stringByAppendingString:@"利用規約とプライバシーポリシーに同意してください\n"];
    }

    if ( message.length > 0 ) {
        alertView.message = message;
        [alertView show];
    }else  {
        [self registerAccount];
    }
}

- (IBAction)didPushLoginAccountButton:(id)sender {
    UIAlertView *alerView = [UIAlertView new];
    alerView.delegate = self;
    alerView.title = @"GamerSeachにログイン";
    alerView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    [alerView textFieldAtIndex:0].placeholder = @"ユーザー名";
    [alerView textFieldAtIndex:1].placeholder = @"パスワード";
    
    alerView.cancelButtonIndex = 0;
    [alerView addButtonWithTitle:@"キャンセル"];
    [alerView bk_addButtonWithTitle:@"ログイン" handler:^{
        [self loginAccount:[alerView textFieldAtIndex:0].text password:[alerView textFieldAtIndex:1].text];
    }];
    
    [alerView show];
}

#pragma mark - Setter methods.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"TermsOfServiceSegue"] ) {
        TextViewController *textVC = segue.destinationViewController;
        textVC.title = @"利用規約";
    }
    
    if ( [segue.identifier isEqualToString:@"PrivacyPolicySegue"] ) {
        TextViewController *textVC = segue.destinationViewController;
        textVC.title = @"プライバシーポリシー";
    }
}
@end

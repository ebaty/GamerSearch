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

- (void)loginFromTwitter {
    PFUser *currentUser = [PFUser currentUser];
    DDLogVerbose(@"%@", currentUser);
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if ( !error ) {
            if ( !user ) {
                DDLogVerbose(@"Uh oh. The user cancelled the Twitter login.");
                return;
            }else {
                DDLogVerbose(@"%@", [PFUser currentUser]);
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] validateAccount];
            }
        }else {
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

- (IBAction)twitterLoginButton:(id)sender {
    if ( _firstCheck && _secondCheck ) {
        
        [self loginFromTwitter];
        
    }else {
        
        UIAlertView *alertView = [UIAlertView new];
        alertView.title = @"";
        alertView.message = @"利用規約とプライバシーポリシーに同意してください";
        alertView.cancelButtonIndex = 0;
        [alertView addButtonWithTitle:@"確認"];
        [alertView show];
        
    }
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

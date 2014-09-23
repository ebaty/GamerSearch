//
//  UserDetailViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/21.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "UserDetailViewController.h"

@interface UserDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fightGamerLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicGamerLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionGamerLabel;

@property (weak, nonatomic) IBOutlet UILabel *psn_idLabel;
@property (weak, nonatomic) IBOutlet UILabel *xbox_liveLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitter_idLabel;

@property (weak, nonatomic) IBOutlet UILabel *checkInAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameCenterLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *followBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rejectBarButton;
@end

@implementation UserDetailViewController

#pragma mark - Init methods.

- (void)viewDidLoad
{
    [super viewDidLoad];

    _userImageView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    _textView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    [self initValues];
    [self initFollowButton];
}

- (void)initValues {
    _userNameLabel.text = _userObject[@"username"];
    
    _psn_idLabel.text = _userObject[@"psn_id"];
    _xbox_liveLabel.text = _userObject[@"xbox_live"];
    _twitter_idLabel.text = _userObject[@"twitter_id"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    _checkInAtLabel.text = [dateFormatter stringFromDate:_userObject[@"checkInAt"]];
    _gameCenterLabel.text = _userObject[@"gameCenter"];
    
    _fightGamerLabel.hidden = ![_userObject[kFightGamerBoolKey] boolValue];
    _musicGamerLabel.hidden = ![_userObject[kMusicGamerBoolKey] boolValue];
    _actionGamerLabel.hidden = ![_userObject[kActionGamerBoolKey] boolValue];
    
    PFFile *userImageFile = _userObject[@"userImage"];
    PFFile *textFile = _userObject[@"comment"];
    
    if ( userImageFile ) {
        [_userImageView showIndicator];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [_userImageView dismissIndicator];
            if ( !error ) {
                _userImageView.image = [UIImage imageWithData:data];
            }else {
                DDLogError(@"%@", error);
            }
        }];
    }
    
    if ( textFile ) {
        _textView.contentSize = CGSizeMake(_textView.frame.size.width, _textView.frame.size.height);
        [_textView showIndicator];
        [textFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [_textView dismissIndicator];
            if ( !error ) {
                _textView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }else {
                DDLogError(@"%@", error);
            }
        }];
    }
}

- (void)initFollowButton {
    PFInstallation *installation = [PFInstallation currentInstallation];
    
    NSString *channelsId = _userObject[@"channelsId"];
    
    if ( ![installation.channels containsObject:channelsId] ) {
        
        self.navigationItem.rightBarButtonItem = _followBarButton;
        
    }else if ( ![channelsId isEqualToString:[PFUser currentUser][@"channelsId"]] ){
    
        self.navigationItem.rightBarButtonItem = _rejectBarButton;
        
    }
}

#pragma mark - UIEvent methods.
- (IBAction)didPushedFollowButton:(UIBarButtonItem *)sender {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObject:_userObject[@"channelsId"] forKey:@"channels"];
    
    sender.enabled = NO;
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            sender.enabled = YES;
            [self initFollowButton];
        }else {
            DDLogError(@"%@", error);
        }
    }];
    
}

- (IBAction)didPushedRejectButton:(UIBarButtonItem *)sender {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObject:_userObject[@"channelsId"] forKey:@"channels"];
    
    sender.enabled = NO;
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            sender.enabled = YES;
            [self initFollowButton];
        }else {
            DDLogError(@"%@", error);
        }
    }];
    
}

@end

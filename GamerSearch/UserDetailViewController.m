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

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UIButton *blockButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelBlockButton;

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
    [self initBlockButton];
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
    if ( [_userObject.objectId isEqualToString:[PFUser currentUser].objectId] ) return;

    if ( [self isBlockUser:_userObject.objectId] ) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    NSString *channelsId = _userObject[@"channelsId"];
    
    if ( ![installation.channels containsObject:channelsId] ) {
        self.navigationItem.rightBarButtonItem = _followBarButton;
    }else {
        self.navigationItem.rightBarButtonItem = _rejectBarButton;
    }
}

- (void)initBlockButton {
    if ( [_userObject.objectId isEqualToString:[PFUser currentUser].objectId] ) return;

    UIColor *ff3300 = [UIColor colorWithRed:1.0f green:0.2f blue:0.0f alpha:1.0f];
    _blockButton.layer.borderColor = ff3300.CGColor;
    _cancelBlockButton.layer.borderColor = ff3300.CGColor;
    
    for ( UIView *view in _emptyView.subviews ) [view removeFromSuperview];
    
    if ( ![self isBlockUser:_userObject.objectId] ) {
        [_emptyView addSubview:_blockButton];
    }else  {
        [_emptyView addSubview:_cancelBlockButton];
    }
    
    [self initFollowButton];

}

- (BOOL)isBlockUser:(NSString *)userId {
    PFUser *currentUser = [PFUser currentUser];
    return [currentUser[@"blockUser"] containsObject:userId];
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

- (IBAction)didPushedBlockButton:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addUniqueObject:_userObject.objectId forKey:@"blockUser"];

    [_blockButton showIndicator];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_blockButton dismissIndicator];
        
        if ( self.navigationItem.rightBarButtonItem == _rejectBarButton )
            [self didPushedRejectButton:_rejectBarButton];

        [self initBlockButton];
    }];
}

- (IBAction)didPushedBlockCancelButton:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:_userObject.objectId forKey:@"blockUser"];

    [_cancelBlockButton showIndicator];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_cancelBlockButton dismissIndicator];
        [self initBlockButton];
    }];
}

@end

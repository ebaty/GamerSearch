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

    // 配色
    _userImageView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    _textView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    UIColor *ff3300 = [UIColor colorWithRed:1.0f green:0.2f blue:0.0f alpha:1.0f];
    _blockButton.layer.borderColor = ff3300.CGColor;
    _cancelBlockButton.layer.borderColor = ff3300.CGColor;

    // 自分以外の時にはindicatorを設定
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [indicatorView showIndicator];
    UIBarButtonItem *indicatorItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    if ( ![_userObject.objectId isEqualToString:[PFUser currentUser].objectId] )
        self.navigationItem.rightBarButtonItem = indicatorItem;
    
    [self initValues];
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
    
    if ( userImageFile && ![userImageFile isEqual:[NSNull null]] ) {
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
    if ( [_userObject.objectId isEqualToString:[PFUser currentUser].objectId] ) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }

    PFRelation *relation = [[PFUser currentUser] relationForKey:@"followUsers"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" equalTo:_userObject.objectId];

    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if ( !error ) {
            if ( number == 0 ) {
                _followBarButton.enabled = YES;
                self.navigationItem.rightBarButtonItem = _followBarButton;
            }else {
                _rejectBarButton.enabled = YES;
                self.navigationItem.rightBarButtonItem = _rejectBarButton;
            }
        }else {
            DDLogError(@"%@", error);
        }
    }];

}

- (void)initBlockButton {
    if ( [_userObject.objectId isEqualToString:[PFUser currentUser].objectId] ) return;
    
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"blockUsers"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" equalTo:_userObject.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if ( !error ) {
            for ( UIView *view in _emptyView.subviews ) [view removeFromSuperview];
            
            if ( number == 0 ) {
                [_blockButton dismissIndicator];
                [_emptyView addSubview:_blockButton];
                [self initFollowButton];
            }else {
                [_cancelBlockButton dismissIndicator];
                [_emptyView addSubview:_cancelBlockButton];
                self.navigationItem.rightBarButtonItem = nil;
            }
        }else {
            DDLogError(@"%@", error);
        }
    }];

}

#pragma mark - UIEvent methods.

- (IBAction)didPushedFollowButton:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow" withParameters:@{@"targetId":_userObject.objectId} block:^(id object, NSError *error) {
        if ( !error ) {
            [self initFollowButton];
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

- (IBAction)didPushedUnfollowButton:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    [PFCloud callFunctionInBackground:@"unfollow" withParameters:@{@"targetId":_userObject.objectId} block:^(id object, NSError *error) {
        if ( !error ) {
            [self initFollowButton];
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

- (IBAction)didPushedBlockButton:(id)sender {
    [_blockButton showIndicator];
    [PFCloud callFunctionInBackground:@"unfollow" withParameters:@{@"targetId":_userObject.objectId} block:^(id object, NSError *error) {
        if ( !error ) {
            [PFCloud callFunctionInBackground:@"block" withParameters:@{@"targetId":_userObject.objectId} block:^(id object, NSError *error) {
                if ( !error ) {
                    DDLogVerbose(@"%@", object);
                    
                    if ( self.navigationItem.rightBarButtonItem == _rejectBarButton )
                        [self didPushedUnfollowButton:_rejectBarButton];
                    
                    [self initBlockButton];
                }else {
                    DDLogError(@"%@", error);
                }
            }];    
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

- (IBAction)didPushedBlockCancelButton:(id)sender {
    [_cancelBlockButton showIndicator];
    [PFCloud callFunctionInBackground:@"unblock" withParameters:@{@"targetId":_userObject.objectId} block:^(id object, NSError *error) {
        if ( !error ) {
            [self initBlockButton];
        }else {
            DDLogError(@"%@", error);
        }
    }];
}
@end

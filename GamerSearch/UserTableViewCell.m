//
//  UserTableViewCell.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/18.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "UserTableViewCell.h"

@interface UserTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *fightGamerLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicGamerLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionGamerLabel;

@end

@implementation UserTableViewCell

- (void)setUserProfileObject:(PFObject *)userProfileObject {
    PFFile *userImageFile = _userProfileObject[@"userImage"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            _userImageView.image = [UIImage imageWithData:imageData];
        }else {
            DDLogError(@"%@", error);
        }
    }];
    
    _userNameLabel.text = _userProfileObject[@"userName"];

    NSDate *checkInDate = _userProfileObject[@"checkInDate"];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    _checkInDateLabel.text = [dateFormatter stringFromDate:checkInDate];
    
    if ( [_userProfileObject[@"fightGamer"]  boolValue]  ) _fightGamerLabel.hidden  = NO;
    if ( [_userProfileObject[@"musicGamer"]  boolValue]  ) _musicGamerLabel.hidden  = NO;
    if ( [_userProfileObject[@"actionGamer"] boolValue] ) _actionGamerLabel.hidden = NO;
}

@end

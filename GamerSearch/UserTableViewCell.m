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

- (void)awakeFromNib {
    _userImageView.layer.borderColor = UIColor.lightGrayColor.CGColor;
}

- (void)setUserProfileObject:(PFObject *)userProfileObject {
    _userProfileObject = userProfileObject;
    
    PFFile *userImageFile = _userProfileObject[@"userImage"];
    [_userImageView showIndicator];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        [_userImageView dismissIndicator];
        if (!error) {
            _userImageView.image = [UIImage imageWithData:imageData];
        }else {
            DDLogError(@"%@", error);
        }
    }];
    
    _userNameLabel.text = _userProfileObject[@"username"];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    
    _checkInDateLabel.text =
        [NSString stringWithFormat:@"%@ に %@ に来ました",
         [dateFormatter stringFromDate:_userProfileObject[@"checkInAt"]],
         _userProfileObject[@"gameCenter"]
        ];
    
    
    if ( [_userProfileObject[kFightGamerBoolKey]  boolValue] ) _fightGamerLabel.hidden  = NO;
    if ( [_userProfileObject[kMusicGamerBoolKey]  boolValue] ) _musicGamerLabel.hidden  = NO;
    if ( [_userProfileObject[kActionGamerBoolKey] boolValue] ) _actionGamerLabel.hidden = NO;    
}

@end

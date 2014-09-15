//
//  MarkerDetailView.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MarkerDetailView.h"

@interface MarkerDetailView ()

@property (nonatomic) UILabel *userLabel;
@property (nonatomic) UILabel *fightLabel;
@property (nonatomic) UILabel *musicLabel;
@property (nonatomic) UILabel *actionLabel;

@property (nonatomic) UILabel *gameUserLabel;
@property (nonatomic) UILabel *fightGameUserLabel;
@property (nonatomic) UILabel *musicGameUserLabel;
@property (nonatomic) UILabel *actionGameUserLabel;

@end

@implementation MarkerDetailView

#pragma mark - Init methods.
- (id)init {
    self = [super init];
    if ( self ) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        
        [self initUI];
        [self layout];
    }
    return self;
}

- (void)initUI {
    _userLabel   = [UILabel new];
    _fightLabel  = [UILabel new];
    _musicLabel  = [UILabel new];
    _actionLabel = [UILabel new];
    
    [[UILabel appearanceWhenContainedIn:[self class], nil] setFont:[UIFont systemFontOfSize:15.0f]];
    
    UILabel *labels[] = {_userLabel, _fightLabel, _musicLabel, _actionLabel};
    NSString *titles[] = {@"総人数", @"格闘ゲーム", @"音楽ゲーム", @"アクションゲーム"};
    for ( int i = 0; i < 4; ++i ) {
        labels[i].text = titles[i];
        labels[i].textAlignment = NSTextAlignmentLeft;
    }
    
    _gameUserLabel = [UILabel new];
    _fightGameUserLabel = [UILabel new];
    _musicGameUserLabel = [UILabel new];
    _actionGameUserLabel = [UILabel new];
}

- (void)layout {
    [self showIndicator];
}

- (void)afterLayout {
    [self dismissIndicator];
    
    NSArray *views = @[_userLabel, _gameUserLabel,
                       _fightLabel,  _fightGameUserLabel,
                       _musicLabel,  _musicGameUserLabel,
                       _actionLabel, _actionGameUserLabel];
    
    for ( UIView *view in views ) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }
    
    NSDictionary *viewsDictionary =
        NSDictionaryOfVariableBindings(_userLabel, _gameUserLabel,
                                       _fightLabel, _fightGameUserLabel,
                                       _musicLabel, _musicGameUserLabel,
                                       _actionLabel, _actionGameUserLabel);
    
    NSString *formats[] = {
        @"H:|-8-[_userLabel]-[_gameUserLabel]-8-|",
        @"H:|-8-[_fightLabel]-[_fightGameUserLabel]-8-|",
        @"H:|-8-[_musicLabel]-[_musicGameUserLabel]-8-|",
        @"H:|-8-[_actionLabel]-[_actionGameUserLabel]-8-|",
        @"V:|-5-[_userLabel]-[_fightLabel]-[_musicLabel]-[_actionLabel]-5-|",
        @"V:|-5-[_gameUserLabel]-[_fightGameUserLabel]-[_musicGameUserLabel]-[_actionGameUserLabel]-5-|"
    };
    
    NSUInteger options[] = {
        NSLayoutFormatAlignAllCenterY,
        NSLayoutFormatAlignAllCenterY,
        NSLayoutFormatAlignAllCenterY,
        NSLayoutFormatAlignAllCenterY,
        0,
        0
    };
    for ( int i = 0; i < 6
         ; ++i ) {
        NSArray *constraints =
            [NSLayoutConstraint constraintsWithVisualFormat:formats[i]
                                                    options:options[i]
                                                    metrics:nil
                                                      views:viewsDictionary];
        [self addConstraints:constraints];
    }
    
}

- (void)didMoveToSuperview {
    self.frame = self.superview.bounds;
}

#pragma mark - Setter methods.
- (void)setGameCetnerName:(NSString *)gameCetnerName {
    _gameCetnerName = gameCetnerName;
    
    DDLogVerbose(@"gameCetnerName:%@", gameCetnerName);
    [PFController queryGameCenterUser:gameCetnerName handler:^(NSArray *users) {
        // 各PFObjectをから各ジャンルの人数を取得・ラベルに設定
        int fightUser = 0;
        int musicUser = 0;
        int actionUser = 0;
        
        for ( PFObject *user in users ) {
            if ( [user[@"fightUser"] isEqual:@YES]  ) ++fightUser;
            if ( [user[@"musicUser"] isEqual:@YES]  ) ++musicUser;
            if ( [user[@"actionUser"] isEqual:@YES] ) ++actionUser;
        }
        
        UILabel *labels[] = {_gameUserLabel, _fightGameUserLabel, _musicGameUserLabel, _actionGameUserLabel};
        int params[] = {users.count, fightUser, musicUser, actionUser};
        for ( int i = 0; i < 4; ++i ) {
            labels[i].text = [NSString stringWithFormat:@"%d人", params[i]];
            labels[i].textAlignment = NSTextAlignmentRight;
        }
        
        [self afterLayout];
    }];
}

@end

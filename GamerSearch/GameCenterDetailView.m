//
//  GameCenterDetailView.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "GameCenterDetailView.h"

@interface GameCenterDetailView ()

@property (nonatomic) UILabel *fightGameUserLabel;
@property (nonatomic) UILabel *musicGameUserLabel;
@property (nonatomic) UILabel *actionGameUserLabel;

@property (nonatomic) NSArray *users;

@end

@implementation GameCenterDetailView

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
    
}

- (void)layout {
    
}

#pragma mark - Setter methods.
- (void)setGameCetnerName:(NSString *)gameCetnerName {
    _gameCetnerName = gameCetnerName;
    
}

- (void)setUsers:(NSArray *)users {
    _users = users;
    
}

@end

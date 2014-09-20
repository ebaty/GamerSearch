//
//  ParseController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "PFController.h"

#define kGameCenterClassName    @"GameCenter"
#define kPlayerProfileClassName @"PlayerProfile"

@implementation PFController

#pragma mark - Query methods.
+ (void)queryGameCenter:(void (^)(NSArray *gameCenters))block {
    PFQuery *query = [PFQuery queryWithClassName:kGameCenterClassName];
    
    [query whereKey:@"show" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            block(objects);
        }else {
            DDLogError(@"%@", error);
        }
        
    }];
}

static NSMutableDictionary *gameCenterUserCache = nil;
+ (void)queryGameCenterUser:(NSString *)gameCenterName useCache:(BOOL)useCache handler:(void (^)(NSArray *users))block {
    if ( !gameCenterUserCache ) {
        gameCenterUserCache = [NSMutableDictionary new];
    }else {
        if ( useCache ) {
            NSArray *users = gameCenterUserCache[gameCenterName];
            if ( users ) block(users);
        }
    }

    PFQuery *query = [PFQuery queryWithClassName:kPlayerProfileClassName];
    
    [query whereKey:@"gameCenterName" equalTo:gameCenterName];
    [query orderByDescending:@"updatedAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            DDLogVerbose(@"%@", objects);
            [gameCenterUserCache setObject:objects forKey:gameCenterName];
            block(objects);
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

+ (void)queryFollowUser:(void (^)(NSArray *followUser))block {
    PFInstallation *installation = [PFInstallation currentInstallation];
    
    PFQuery *query = [PFQuery queryWithClassName:kPlayerProfileClassName];

    [query whereKey:@"objectId" containedIn:installation[@"channels"]];
    [query orderByDescending:@"updatedAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            block(objects);
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

#pragma mark - Post methods.
+ (void)postGameCenter:(NSString *)gameCenterName coordinate:(CLLocationCoordinate2D)coordinate{
    PFObject *gameCenterObject = [PFObject objectWithClassName:kGameCenterClassName];
    gameCenterObject[@"name"] = gameCenterName;
    gameCenterObject[@"geoPoint"] = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    gameCenterObject[@"show"] = @NO;
    
    [SVProgressHUD showWithStatus:@"リクエストを送信中です..." maskType:SVProgressHUDMaskTypeBlack];
    [gameCenterObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( succeeded )
            [SVProgressHUD showSuccessWithStatus:@"リクエストの送信を完了しました"];
        else
            [SVProgressHUD showErrorWithStatus:@"リクエストの送信に失敗しました"];
    }];
}

+ (void)postUserProfile:(NSDictionary *)params handler:(void (^)(void))block {
    PFUser *currentUser = [PFUser currentUser];
    for ( NSString *key in params ) {
        currentUser[key] = params[key];
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block();
        DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    }];
}

@end

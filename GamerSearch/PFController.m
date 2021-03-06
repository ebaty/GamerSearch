//
//  ParseController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "PFController.h"

#define kGameCenterClassName @"GameCenter"
#define kGameCenterArraykey  @"GameCenterArray"

@implementation PFController

#pragma mark - Query methods.

#pragma mark GameCenter
+ (void)queryGameCenter:(void (^)(NSArray *gameCenters))block {
    PFQuery *query = [PFQuery queryWithClassName:kGameCenterClassName];
    
    block( [USER_DEFAULTS arrayForKey:kGameCenterArraykey] );
    
    [query whereKey:@"show" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            [self saveGameCenter:objects];
            block( [USER_DEFAULTS arrayForKey:kGameCenterArraykey] );
        }else {
            DDLogError(@"%@", error);
        }
        
    }];
}

+ (void)saveGameCenter:(NSArray *)gameCenters {
    NSMutableArray *gameCenterArray = [NSMutableArray new];

    for ( PFObject *gameCenter in gameCenters ) {
        NSMutableDictionary *gameCenterDictionary = [NSMutableDictionary new];
        
        gameCenterDictionary[@"name"] = gameCenter[@"name"];
        
        PFGeoPoint *geoPoint = gameCenter[@"geoPoint"];
        gameCenterDictionary[@"latitude"]  = @(geoPoint.latitude);
        gameCenterDictionary[@"longitude"] = @(geoPoint.longitude);
        
        [gameCenterArray addObject:gameCenterDictionary];
    }
    
    [USER_DEFAULTS setObject:gameCenterArray forKey:kGameCenterArraykey];
    [USER_DEFAULTS synchronize];
}

#pragma mark User
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

    [PFCloud callFunctionInBackground:@"gamecenter_user" withParameters:@{@"gameCenter":gameCenterName} block:^(id object, NSError *error) {
        if ( !error ) {
            [gameCenterUserCache setObject:object forKey:gameCenterName];
            block(object);
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
    
    PFACL *gameCenterACL = [PFACL ACL];
    [gameCenterACL setPublicReadAccess:YES];
    [gameCenterACL setPublicWriteAccess:YES];
    gameCenterObject.ACL = gameCenterACL;
    
    [SVProgressHUD showWithStatus:@"リクエストを送信中です..." maskType:SVProgressHUDMaskTypeBlack];
    [gameCenterObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( succeeded )
            [SVProgressHUD showSuccessWithStatus:@"リクエストの送信を完了しました"];
        else
            [SVProgressHUD showErrorWithStatus:@"リクエストの送信に失敗しました"];
    }];
}

+ (void)postUserProfile:(NSDictionary *)params progress:(BOOL)progress handler:(void (^)(void))block {
    PFUser *currentUser = [PFUser currentUser];
    
    if ( !currentUser ) return;
    
    for ( NSString *key in params.allKeys ) {
        currentUser[key] = params[key];
    }
    
    if ( progress ) [SVProgressHUD showWithStatus:@"ユーザー情報を更新しています..." maskType:SVProgressHUDMaskTypeBlack];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            if ( progress ) [SVProgressHUD showSuccessWithStatus:@"ユーザー情報を更新しました"];
            if ( block ) block();
        }else {
            if ( error.code == 202 ) {
                if ( progress ) [SVProgressHUD showErrorWithStatus:@"既に使用されているユーザー名です"];
            }else {
                if ( progress ) [SVProgressHUD showErrorWithStatus:@"ユーザー情報の更新に失敗しました"];
            }
            DDLogError(@"%@", error);
        }
    }];
}

#pragma mark - Other method.
+ (NSArray *)getObjectIdArray:(NSArray *)objects {
    NSMutableArray *objectIdArray = [NSMutableArray new];
    for ( PFUser *object in objects ) {
        [objectIdArray addObject:object.objectId];
    }
    return objectIdArray;
}
@end

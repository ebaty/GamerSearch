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
+ (void)queryGameCenterUser:(NSString *)gameCenterName handler:(void (^)(NSArray *users))block {
    PFQuery *query = [PFQuery queryWithClassName:kPlayerProfileClassName];
    
    if ( !gameCenterUserCache ) {
        gameCenterUserCache = [NSMutableDictionary new];
    }else {
        NSArray *users = gameCenterUserCache[gameCenterName];
        if ( users ) block(users);
    }
    
    [query whereKey:@"gameCenterName" equalTo:gameCenterName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            [gameCenterUserCache setObject:objects forKey:gameCenterName];
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
@end

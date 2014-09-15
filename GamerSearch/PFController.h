//
//  ParseController.h
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PFController : NSObject

+ (void)queryGameCenter:(void (^)(NSArray *gameCenters))block;
+ (void)queryGameCenterUser:(NSString *)gameCenterName handler:(void (^)(NSArray *users))block;

+ (void)postGameCenter:(NSString *)gameCenterName coordinate:(CLLocationCoordinate2D)coordinate;

@end

//
//  RegionController.h
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/21.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kPrevGameCenter @"PrevGameCenter"

@interface RegionController : NSObject

@property (nonatomic) NSArray *gameCenters;
@property (nonatomic) CLLocationManager *manager;

+ (instancetype)sharedInstance;

@end

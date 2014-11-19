//
//  RegionController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/21.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "RegionController.h"
#import "BTController.h"

#define kApplication [UIApplication sharedApplication]
#define kRegionRadius 5.0f

@interface RegionController () <CLLocationManagerDelegate>

@property (nonatomic) NSArray *monitoringGameCenters;

@end

@implementation RegionController

static RegionController *instance = nil;

+ (instancetype)sharedInstance {
    if ( !instance ) {
        instance = [RegionController new];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if ( self ) {
        _manager = [CLLocationManager new];
        _manager.delegate = self;
        [_manager startUpdatingLocation];
        
        _nearRegions = [NSMutableSet new];
        
        instance = self;
    }
    return self;
}

- (void)setGameCenters:(NSArray *)gameCenters location:(CLLocation *)myLocation {
    NSMutableArray *sortedGameCenters = [NSMutableArray new];
    
    for ( NSDictionary *gameCenter in gameCenters ) {
        CLLocation *gameCenterLocation =
            [[CLLocation alloc] initWithLatitude:[gameCenter[@"latitude"]  doubleValue]
                                       longitude:[gameCenter[@"longitude"] doubleValue]];
        CLLocationDistance distance = [myLocation distanceFromLocation:gameCenterLocation];
        
        NSMutableDictionary *newParams = [gameCenter mutableCopy];
        [newParams setObject:@(distance) forKey:@"distance"];
        
        [sortedGameCenters addObject:newParams];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
    self.monitoringGameCenters = [sortedGameCenters sortedArrayUsingDescriptors:@[descriptor]];
}

- (void)setMonitoringGameCenters:(NSArray *)monitoringGameCenters {
    _monitoringGameCenters = monitoringGameCenters;
    int count = (int)monitoringGameCenters.count;
    if ( count > 20 ) count = 20;
    
    for ( CLRegion *region in _manager.monitoredRegions ) {
        [_manager stopMonitoringForRegion:region];
    }
    
    for ( int i = 0; i < count; ++i ) {
        NSDictionary *gameCenter = monitoringGameCenters[i];
        
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
        
        CLCircularRegion *region =
            [[CLCircularRegion alloc] initWithCenter:coordinate radius:kRegionRadius identifier:gameCenter[@"name"]];
        
        [_manager startMonitoringForRegion:region];
        [_manager requestStateForRegion:region];
        
        double distance = [gameCenter[@"distance"] doubleValue];
        if ( distance < 100.0f ) {
            [_nearRegions addObject:region];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadCheckInViewController object:self];
}

- (void)checkAllGameCenterDistance:(CLLocation *)nowLocation {
    double minimumDistance = kRegionRadius * 20;
    
    for ( NSDictionary *gameCenter in _monitoringGameCenters ) {
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
        
        CLCircularRegion *region =
            [[CLCircularRegion alloc] initWithCenter:coordinate radius:kRegionRadius identifier:gameCenter[@"name"]];

        CLLocation *regionLocation =
        [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
        CLLocationDistance distance = [nowLocation distanceFromLocation:regionLocation];
        
        DDLogVerbose(@"%@:%lf", region.identifier, distance);
        if ( distance < kRegionRadius * 20 ) {
            if ( distance < minimumDistance ) {
                [self locationManager:_manager didEnterRegion:region];
                minimumDistance = distance;
            }
        }else {
            [self locationManager:_manager didExitRegion:region];
        }
    }
    
}

#pragma mark - CLLocationManager delegate methods.

#pragma mark 位置情報更新
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *nowLocation = locations.lastObject;
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    
    if ( _gameCenters ) {
        [self setGameCenters:_gameCenters location:nowLocation];
        [manager stopUpdatingLocation];
        [manager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:5 * 60];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"%@:%@", NSStringFromSelector(_cmd), error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ( state == CLRegionStateInside ) {
        [_nearRegions addObject:region];
    }else {
        [_nearRegions removeObject:region];
    }
    
    DDLogVerbose(@"%@, %d", region, (int)state);
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadCheckInViewController object:self];
}

#pragma mark 領域観測

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [BTController backgroundTask:^{
        if ( ![[PFUser currentUser][@"gameCenter"] isEqualToString:region.identifier] ) {
            [USER_DEFAULTS setObject:region.identifier forKey:kPrevGameCenter];
            [USER_DEFAULTS synchronize];
            
            // デバッグ用
            CLCircularRegion *circular = (CLCircularRegion *)region;
            CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:circular.center.latitude longitude:circular.center.longitude];
            DDLogVerbose(@"%@:%@, distance == %lf",
                         NSStringFromSelector(_cmd), region, [manager.location distanceFromLocation:regionLocation]);
            
            NSString *message = [region.identifier stringByAppendingString:@"の近くに来ました"];
            
            NSDictionary *userInfo =
            @{
              @"message":message,
              @"state":@"EnterRegion",
              @"gameCenter":region.identifier
            };
            
            [self sendLocalNotification:message userInfo:userInfo];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [BTController backgroundTask:^{
        if ( [[PFUser currentUser][@"gameCenter"] isEqualToString:region.identifier] ) {
            NSString *prev = [USER_DEFAULTS stringForKey:kPrevGameCenter];
            if ( prev == region.identifier ) {
                [kApplication cancelAllLocalNotifications];
                DDLogVerbose(@"equal prev identifier");
                return;
            }
            
            DDLogVerbose(@"%@:%@", NSStringFromSelector(_cmd), region);
            
            NSString *message = [region.identifier stringByAppendingString:@"から離れました"];
            
            NSDictionary *userInfo =
            @{
              @"message":message,
              @"state":@"ExitRegion",
              @"gameCenter":region.identifier
            };
            
            [self sendLocalNotification:message userInfo:userInfo];
        }
    }];
}

#pragma mark - Send notification method.
- (void)sendLocalNotification:(NSString *)message userInfo:(NSDictionary *)userInfo{
    [kApplication cancelAllLocalNotifications];
    
    NSTimeInterval interval = 5;
    if ( kApplication.applicationState != UIApplicationStateActive )
        interval = 1 * 60;

    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate  = [NSDate dateWithTimeIntervalSinceNow:interval];
    notification.alertBody = message;
    notification.timeZone  = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = userInfo;

    [kApplication scheduleLocalNotification:notification];
}

@end

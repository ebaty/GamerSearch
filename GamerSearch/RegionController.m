//
//  RegionController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/21.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "RegionController.h"

@interface RegionController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) NSArray *monitoringGameCenters;

@end

@implementation RegionController

- (id)init {
    self = [super init];
    if ( self ) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        [_manager startUpdatingLocation];
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
    int count = monitoringGameCenters.count;
    if ( count > 20 ) count = 20;
    
    for ( int i = 0; i < count; ++i ) {
        NSDictionary *gameCenter = monitoringGameCenters[i];
        
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
        
        CLCircularRegion *region =
            [[CLCircularRegion alloc] initWithCenter:coordinate radius:100.0f identifier:gameCenter[@"name"]];
        
        [_manager startMonitoringForRegion:region];
        [_manager requestStateForRegion:region];
    }
    
}

#pragma mark - CLLocationManager delegate methods.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *nowLocation = locations.lastObject;
    
    if ( _gameCenters ) {
        [self setGameCenters:_gameCenters location:nowLocation];
    }
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"%@:%@", NSStringFromSelector(_cmd), error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSArray *stateArray = @[@"CLRegionStateUnknown",
                            @"CLRegionStateInside",
                            @"CLRegionStateOutside"];
    DDLogVerbose(@"%@:%@", region.identifier, stateArray[state]);
    
    if ( state == CLRegionStateInside ) {
        if ( ![region.identifier isEqualToString:[PFUser currentUser][@"gameCenter"]] ) {
            [self locationManager:manager didEnterRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    DDLogVerbose(@"%@:%@", NSStringFromSelector(_cmd), region);
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"gameCenter"] = region.identifier;
    currentUser[@"checkInAt"]  = [NSDate date];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            [self sendPushNotification];
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    DDLogVerbose(@"%@:%@", NSStringFromSelector(_cmd), region);
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"gameCenter"] = [region.identifier stringByAppendingString:@"を出ました"];
    currentUser[@"checkInAt"]  = [NSDate date];
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ( !error ) {
            [self sendLocalNotification:currentUser[@"gameCenter"]];
        }else {
            DDLogError(@"%@", error);
        }
    }];
}

#pragma mark - Send notification methods.
- (void)sendPushNotification {
    PFUser *currentUser = [PFUser currentUser];

    NSString *message =
        [NSString stringWithFormat:@"%@ が %@ に来ました", currentUser[@"username"], currentUser[@"gameCenter"]];
    
    NSDictionary *pushData =
    @{
      @"alert":message,
      @"badge":@"Increment"
    };
    
    [PFPush sendPushDataToChannelInBackground:currentUser[@"channelsId"]
                                     withData:pushData
                                        block:
     ^(BOOL succeeded, NSError *error) {
         if ( !error ) {
             NSString *message =
                [NSString stringWithFormat:@"%@ に来ました", currentUser[@"gameCenter"]];
             [self sendLocalNotification:message];
         }else {
             DDLogError(@"%@", error);
         }
    }];
}

- (void)sendLocalNotification:(NSString *)message {
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate  = [NSDate date];
    notification.alertBody = message;
    notification.timeZone  = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end

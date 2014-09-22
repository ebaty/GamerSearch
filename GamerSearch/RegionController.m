//
//  RegionController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/21.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "RegionController.h"

#define kRegionRadius 5.0f

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
    int count = (int)monitoringGameCenters.count;
    if ( count > 20 ) count = 20;
    
    for ( CLRegion *region in _manager.monitoredRegions ) {
        [_manager stopMonitoringForRegion:region];
    }
    
    DDLogVerbose(@"%@", monitoringGameCenters);
    for ( int i = 0; i < count; ++i ) {
        NSDictionary *gameCenter = monitoringGameCenters[i];
        
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
        
        CLCircularRegion *region =
            [[CLCircularRegion alloc] initWithCenter:coordinate radius:kRegionRadius identifier:gameCenter[@"name"]];
        
        [_manager startMonitoringForRegion:region];
        [_manager requestStateForRegion:region];
    }
    
}

- (void)checkBackgroundTask {
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 既に実行済みであれば終了する
            if (bgTask != UIBackgroundTaskInvalid) {
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
}

- (void)checkDistance:(NSDictionary *)gameCenter nowLocation:(CLLocation *)nowLocation {
    if ( gameCenter ) {
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
        
        CLLocation *gameCenterLocation =
            [[CLLocation alloc] initWithLatitude:[gameCenter[@"latitude"]  doubleValue]
                                       longitude:[gameCenter[@"longitude"] doubleValue]];
        
        CLCircularRegion *region =
            [[CLCircularRegion alloc] initWithCenter:coordinate radius:kRegionRadius identifier:gameCenter[@"name"]];
        
        CLLocationDistance distance = [nowLocation distanceFromLocation:gameCenterLocation];

        if ( distance <= kRegionRadius * 20 ) {
            [self locationManager:_manager didEnterRegion:region];
        }else {
            [self locationManager:_manager didExitRegion:region];
        }
    }
}

#pragma mark - CLLocationManager delegate methods.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *nowLocation = locations.lastObject;
    
    if ( _gameCenters ) {
        [self setGameCenters:_gameCenters location:nowLocation];
        [self checkDistance:_monitoringGameCenters.firstObject nowLocation:nowLocation];
    }
    
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));

    [manager stopUpdatingLocation];
    [manager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:1 * 60];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"%@:%@", NSStringFromSelector(_cmd), error);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSArray *stateArray = @[@"CLRegionStateUnknown",
                            @"CLRegionStateInside",
                            @"CLRegionStateOutside"];
    
    CLCircularRegion *r = (CLCircularRegion *)region;
    CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:r.center.latitude longitude:r.center.longitude];
    DDLogVerbose(@"%@:%@, %lf", region.identifier, stateArray[state], [manager.location distanceFromLocation:regionLocation]);

//    if ( state == CLRegionStateInside && ![region.identifier isEqualToString:[PFUser currentUser][@"gameCenter"]] ) {
//        if ( [manager.location distanceFromLocation:regionLocation] <= kRegionRadius ) {
//            [self locationManager:manager didEnterRegion:region];
//        }
//    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self checkBackgroundTask];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        if ( ![region.identifier isEqualToString:[PFUser currentUser][@"gameCenter"]] ) {

            CLCircularRegion *circular = (CLCircularRegion *)region;
            CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:circular.center.latitude longitude:circular.center.longitude];
            DDLogVerbose(@"%@:%@, distance == %lf",
                         NSStringFromSelector(_cmd), region, [manager.location distanceFromLocation:regionLocation]);
            
            NSDictionary *params =
            @{
              @"gameCenter" : region.identifier,
              @"checkInAt"  : [NSDate date]
            };
            
            [PFController postUserProfile:params handler:^{
                [self sendPushNotification];
            }];
        }

    });
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self checkBackgroundTask];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        DDLogVerbose(@"%@:%@", NSStringFromSelector(_cmd), region);
        
        if ( [region.identifier isEqualToString:[PFUser currentUser][@"gameCenter"]] ) {
            
            NSString *message = [region.identifier stringByAppendingString:@" を出ました"];
            
            NSDictionary *params =
            @{
              @"gameCenter" : @"",
              @"checkInAt"  : [NSDate date]
            };

            [PFController postUserProfile:params handler:^{
                [self sendLocalNotification:message];
            }];
        }
        
    });
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

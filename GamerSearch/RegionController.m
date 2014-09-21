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

@end

@implementation RegionController

- (id)init {
    self = [super init];
    if ( self ) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return self;
}

- (void)startMonitoringGameCenter:(NSArray *)gameCenters {
    if ( [CLLocationManager locationServicesEnabled] ) {
        for ( CLRegion *region in _manager.monitoredRegions ) {
            [_manager stopMonitoringForRegion:region];
        }
        
        for ( NSDictionary *gameCenter in gameCenters ) {
            CLLocationCoordinate2D coordinate =
                CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
            
            CLCircularRegion *region =
                [[CLCircularRegion alloc] initWithCenter:coordinate radius:100.0f identifier:gameCenter[@"name"]];
            
            [_manager startMonitoringForRegion:region];
        }
    }
}

#pragma mark - CLLocationManager delegate methods.
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
            NSString *message =
                [NSString stringWithFormat:@"%@ を出ました", currentUser[@"gameCenter"]];
            [self sendLocalNotification:message];
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
         if ( error ) {
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

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

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    // ここで任意の処理
    DDLogVerbose(@"%s | %@, %@", __PRETTY_FUNCTION__, region, error);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // ここで任意の処理
    DDLogVerbose(@"%s | %@", __PRETTY_FUNCTION__, region);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // ここで任意の処理
    DDLogVerbose(@"%s | %@", __PRETTY_FUNCTION__, region);
}
@end

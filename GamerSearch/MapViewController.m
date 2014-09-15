//
//  MapViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MapViewController.h"
#import "MarkerView.h"

#import <FontAwesomeKit.h>
#import <GoogleMaps.h>

#define kGameCenterArraykey  @"GameCenterArray"

@interface MapViewController () <GMSMapViewDelegate, UIAlertViewDelegate, MarkerViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;

@property (nonatomic) MarkerView *markerWindow;
@end

@implementation MapViewController

#pragma mark - init methods.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    [self setGameCenterMarker];
    
    [PFController queryGameCenter:^(NSArray *gameCenters) {
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
        
        [self setGameCenterMarker];
    }];
}

- (void)setGameCenterMarker {
    [_mapView clear];
    
    NSArray *gameCenterArray = [USER_DEFAULTS arrayForKey:kGameCenterArraykey];
    for ( NSDictionary *gameCenter in gameCenterArray ) {
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] floatValue], [gameCenter[@"longitude"] floatValue]);
        
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate
                                       completionHandler:
         ^(GMSReverseGeocodeResponse *response, NSError *error) {
             GMSAddress *res = [response firstResult];
             marker.snippet = [NSString stringWithFormat:@"%@%@%@", res.locality, res.subLocality, res.thoroughfare];
         }];
        
        marker.title = gameCenter[@"name"];
        marker.appearAnimation = YES;
        marker.map = _mapView;
    }
}

#pragma mark - GMSMapView delegate methods.
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // マーカーリクエストの送信
    GMSMarker *longPressMarker = [GMSMarker markerWithPosition:coordinate];
    longPressMarker.appearAnimation = YES;
    longPressMarker.map = _mapView;
    
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"この場所にマーカー設置のリクエストをしますか？";
    alert.message = @"リクエストの承認には時間が掛かります。";
    alert.delegate = self;
    alert.cancelButtonIndex = 0;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].placeholder = @"ゲームセンター名";
    
    [alert bk_addButtonWithTitle:@"キャンセル" handler:^{
        longPressMarker.map = nil;
    }];
    
    [alert bk_addButtonWithTitle:@"リクエスト" handler:^{
        longPressMarker.map = nil;
        NSString *gameCenterName = [alert textFieldAtIndex:0].text;
        
        if ( gameCenterName.length > 0 ) {
            // GameCenterのPFObejctをPOST
            [PFController postGameCenter:gameCenterName coordinate:coordinate];
        }
    }];
    
    [alert performSelector:@selector(show) withObject:nil afterDelay:0.25f];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _bottomSpace.constant = 160.0f;
    [self.view setNeedsLayout];
    
    [UIView animateWithDuration:0.16 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [_markerWindow removeFromSuperview];
    
    _markerWindow = [MarkerView new];
    _markerWindow.title = marker.title;
    _markerWindow.snipet = marker.snippet;
    _markerWindow.delegate = self;
    
    [_bottomView addSubview:_markerWindow];
    
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    _bottomSpace.constant = 0;
    
    [self.view setNeedsLayout];
    
    [UIView animateWithDuration:0.16 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    return [UIView new];
}

#pragma mark - MarkerView delegate methods.
- (void)didPushedMarkerViewButton {
    [self performSegueWithIdentifier:@"userListSegue" sender:nil];
}

@end

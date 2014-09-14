//
//  MapViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MapViewController.h"

#import <Parse.h>
#import <FontAwesomeKit.h>
#import <GoogleMaps.h>

#define kGameCenterClassName @"GameCenter"
#define kGameCenterArraykey  @"GameCenterArray"

@interface MapViewController () <GMSMapViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController

#pragma mark - init methods.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    [self setGameCenterMarker];
    [self queryGameCenter];
}

- (void)setGameCenterMarker {
    [_mapView clear];
    
    NSArray *gameCenterArray = [USER_DEFAULTS arrayForKey:kGameCenterArraykey];
    for ( NSDictionary *gameCenter in gameCenterArray ) {
        CLLocationCoordinate2D coordinate =
            CLLocationCoordinate2DMake([gameCenter[@"latitude"] floatValue], [gameCenter[@"longitude"] floatValue]);
        
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        marker.title = gameCenter[@"name"];

        marker.appearAnimation = YES;
        marker.map = _mapView;
    }
}

#pragma mark - Parse methods.
- (void)queryGameCenter {
    PFQuery *query = [PFQuery queryWithClassName:kGameCenterClassName];
    
    [query whereKey:@"show" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ( !error ) {
            NSMutableArray *gameCenterArray = [NSMutableArray new];
            
            for ( PFObject *object in objects ) {
                NSMutableDictionary *gameCenterDictionary = [NSMutableDictionary new];
                
                gameCenterDictionary[@"name"] = object[@"name"];
                
                PFGeoPoint *geoPoint = object[@"geoPoint"];
                gameCenterDictionary[@"latitude"]  = @(geoPoint.latitude);
                gameCenterDictionary[@"longitude"] = @(geoPoint.longitude);
                
                [gameCenterArray addObject:gameCenterDictionary];
            }
            
            [USER_DEFAULTS setObject:gameCenterArray forKey:kGameCenterArraykey];
            [USER_DEFAULTS synchronize];
            
            [self setGameCenterMarker];
        }

    }];
}

- (void)postGameCenter:(NSString *)gameCenterName coordinate:(CLLocationCoordinate2D)coordinate{
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
            [self postGameCenter:gameCenterName coordinate:coordinate];
        }
    }];
    
    [alert performSelector:@selector(show) withObject:nil afterDelay:0.25f];
}

@end

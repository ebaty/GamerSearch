//
//  MapViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MapViewController.h"
#import "MarkerView.h"
#import "UserListViewController.h"
#import "RegionController.h"

#import <FontAwesomeKit.h>
#import <GoogleMaps.h>

#define kGameCenterArraykey  @"GameCenterArray"

@interface MapViewController () <GMSMapViewDelegate, UIAlertViewDelegate, MarkerViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;

@property (nonatomic) MarkerView *markerWindow;

@property (nonatomic) RegionController *regionControlelr;

@end

@implementation MapViewController

#pragma mark - init methods.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // GMSMapViewの初期設定
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;

    // 初期位置設定
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(36.204824, 138.252924);
    _mapView.camera = [GMSCameraPosition cameraWithTarget:coordinate zoom:4.0f];
    
    _regionControlelr = [RegionController new];
    [self setUpGameCenterMarker];
}

- (void)setUpGameCenterMarker {
    [PFController queryGameCenter:^(NSArray *gameCenters) {
        [_mapView clear];
        
        for ( NSDictionary *gameCenter in gameCenters ) {
            CLLocationCoordinate2D coordinate =
                CLLocationCoordinate2DMake([gameCenter[@"latitude"] doubleValue], [gameCenter[@"longitude"] doubleValue]);
            
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
        [_regionControlelr startMonitoringGameCenter:gameCenters];
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

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    _mapView.camera = [GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:13.0];

    return YES;
}

#pragma mark - MarkerView delegate method.
- (void)didPushedMarkerViewButton {
    [self performSegueWithIdentifier:@"userListSegue" sender:_markerWindow.title];
}

#pragma mark - Segue method.
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:@"userListSegue"] ) {
        UserListViewController *nextViewController = [segue destinationViewController];
        nextViewController.gameCenterName = sender;
    }
}

@end

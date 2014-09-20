//
//  AppDelegate.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "AppDelegate.h"

#import <GoogleMaps.h>
#import <LumberjackConsole/PTEDashboard.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"X10PAkGYt5ciyoQLTbETqAP7y4mryJhvV3I8gHxX" clientKey:@"oW2ovnBosQDTlpoSlFhtVTTqLFWf3DC3zoGb6top"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Push通知の設定
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // GoogleMapsSDKの設定
    [GMSServices provideAPIKey:@"AIzaSyDgD8tx7qi2nO-63xOCapi5gsbCI-XHHFE"];
    
    // CocoaLumberjackの設定
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // LumberjackConsoleの設定
    [[PTEDashboard sharedDashboard] show];

    if ( ![[USER_DEFAULTS objectForKey:@"didFirstLaunch"] boolValue] ) {
        [PFController postUserProfile:nil handler:^{
            [USER_DEFAULTS setObject:@YES forKey:@"didFirstLaunch"];
            [USER_DEFAULTS synchronize];
        }];
    }

    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}
@end

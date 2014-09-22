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

#ifdef DEBUG
    // CocoaLumberjackの設定
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/"];
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logPath];
    // ファイルにログを出力
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    // 1日に1回ログファイルを更新
    // fileLogger.rollingFrequency =   60 * 60 * 24;
    // 10秒に1回ログファイルを更新
    fileLogger.rollingFrequency =   10;
    // ログファイルを残す数
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    // Xcodeのコンソールにログを出力
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:fileLogger];
    
    // LumberjackConsoleの設定
    [[PTEDashboard sharedDashboard] show];
#endif

    // PFUserの初期化
    if ( ![USER_DEFAULTS boolForKey:@"didFirstLaunch"] ) {
        [PFController postUserProfile:nil handler:^{
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"username"] = @"未設定";
            currentUser[@"channelsId"] = [@"channelsId_" stringByAppendingString:currentUser.objectId];
            [currentUser saveInBackground];

            [USER_DEFAULTS setBool:YES forKey:@"didFirstLaunch"];
            [USER_DEFAULTS synchronize];
        }];
    }
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    return YES;
}

BOOL didCalledFetch = NO;
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 既に実行済みであれば終了する
            if (bgTask != UIBackgroundTaskInvalid) {
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performSelector:@selector(callCompletionHandler:) withObject:completionHandler afterDelay:1 * 60];
    });
}

- (void)callCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
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

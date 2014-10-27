//
//  AppDelegate.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "AppDelegate.h"
#import "RegionController.h"
#import "BTController.h"

#import <GoogleMaps.h>
#import <LumberjackConsole/PTEDashboard.h>

#define kGameCenterArraykey  @"GameCenterArray"

@interface AppDelegate () <UIAlertViewDelegate>

@property (nonatomic) RegionController *regController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parseの初期設定
    [Parse setApplicationId:@"X10PAkGYt5ciyoQLTbETqAP7y4mryJhvV3I8gHxX"
                  clientKey:@"oW2ovnBosQDTlpoSlFhtVTTqLFWf3DC3zoGb6top"];

    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [PFTwitterUtils initializeWithConsumerKey:@"NIO5ybtx2SJcs3KnMt5KXxP1R"
                               consumerSecret:@"fZpgW164mladR8EDbnV2aoyx3P2cebnrTRDVefWfODTZxQxnF5"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // GoogleMapsSDKの設定
    [GMSServices provideAPIKey:@"AIzaSyDgD8tx7qi2nO-63xOCapi5gsbCI-XHHFE"];

#ifdef DEBUG
    // CocoaLumberjackの設定
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Logs/"];
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
    [DDLog addLogger:fileLogger];
    
    // LumberjackConsoleの設定
    [[PTEDashboard sharedDashboard] show];
#endif

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self validateAccount];
    
    return YES;
}

- (void)validateAccount {
    PFUser *currentUser = [PFUser currentUser];
    UIStoryboard *currentStoryboard;
    
    if ( currentUser ) {
        currentStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        
        // Push通知の設定
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }else {
        currentStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
    }
    
    _window.rootViewController = [currentStoryboard instantiateInitialViewController];
    [_window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    [self reloadMonitoringTarget];
    [self performSelector:@selector(callCompletionHandler:) withObject:completionHandler afterDelay:10.0f];
}

- (void)reloadMonitoringTarget {
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    _regController = [RegionController new];
    _regController.gameCenters = [USER_DEFAULTS arrayForKey:kGameCenterArraykey];
}

- (void)callCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveInBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
}

#pragma mark - Notification methods.

#pragma mark Remote
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogVerbose(@"%@:%@", NSStringFromSelector(_cmd), userInfo);
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

#pragma mark Local
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [USER_DEFAULTS setObject:@"" forKey:kPrevGameCenter];
    [USER_DEFAULTS synchronize];
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *gameCenter = userInfo[@"gameCenter"];
    
    if ( [userInfo[@"state"] isEqualToString:@"EnterRegion"] ) {
        UIAlertView *alertView = [UIAlertView new];
        alertView.delegate = self;
        alertView.title = [gameCenter stringByAppendingString:@"にチェックインしますか？"];
        alertView.message = @"チェックインすると他ユーザーに公開されます。";
        alertView.cancelButtonIndex = 0;
        
        [alertView addButtonWithTitle:@"キャンセル"];
        [alertView bk_addButtonWithTitle:@"チェックイン" handler:^{
            [PFCloud callFunctionInBackground:@"check_in" withParameters:@{@"gameCenter":gameCenter} block:^(id object, NSError *error) {
                if ( !error ) {
                    [[PFUser currentUser] refresh];
                }else {
                    DDLogError(@"%@", error);
                }
            }];
        }];
        
        [alertView show];
    }
    if ( [userInfo[@"state"] isEqualToString:@"ExitRegion"] ) {
        [PFCloud callFunctionInBackground:@"check_out" withParameters:@{@"gameCenter":gameCenter} block:^(id object, NSError *error) {
            if ( !error ) {
                [[PFUser currentUser] refresh];
            }else {
                DDLogError(@"%@", error);
            }
        }];
    }
}

@end

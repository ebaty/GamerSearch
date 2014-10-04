//
//  BTController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/03.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "BTController.h"

#define kApplication [UIApplication sharedApplication]
@implementation BTController

+ (void)checkBackgroundTask {
    __block UIBackgroundTaskIdentifier bgTask = [kApplication beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 既に実行済みであれば終了する
            if (bgTask != UIBackgroundTaskInvalid) {
                [kApplication endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
}

+ (void)backgroundTask:(void (^)(void))task{
    [self checkBackgroundTask];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        task();
    });
}

@end

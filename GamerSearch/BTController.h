//
//  BTController.h
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/03.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTController : NSObject

+ (void)backgroundTask:(void (^)(void))task;

@end

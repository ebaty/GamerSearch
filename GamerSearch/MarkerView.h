//
//  MarkerView.h
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MarkerView;
@protocol MarkerViewDelegate <NSObject>

- (void)didPushedMarkerViewButton;

@end

@interface MarkerView : UIView

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *snipet;

@property (nonatomic) id<MarkerViewDelegate> delegate;

@end

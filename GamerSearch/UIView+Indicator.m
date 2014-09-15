//
//  UIView+Indicator.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "UIView+Indicator.h"

@implementation UIView (Indicator)

- (void)showIndicator {
    UIActivityIndicatorView *indicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.backgroundColor = UIColor.whiteColor;

    indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:indicatorView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(indicatorView);
    
    NSString *format[] = {
        @"H:|[_indicatorView]|",
        @"V:|[_indicatorView]|"
    };
    
    for ( int i = 0; i < 2; ++i ) {
        NSArray *constraints =
            [NSLayoutConstraint constraintsWithVisualFormat:format[i]
                                                    options:0
                                                    metrics:nil
                                                      views:viewsDictionary];
        [self addConstraints:constraints];
    }
}

- (void)dismissIndicator {
    for ( UIView *view in self.subviews ) {
        if ( [view isKindOfClass:[UIActivityIndicatorView class]] )
            [view removeFromSuperview];
    }
}

@end

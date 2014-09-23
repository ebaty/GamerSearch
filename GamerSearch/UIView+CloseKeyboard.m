//
//  UIView+CloseKeyboard.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/23.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "UIView+CloseKeyboard.h"

@implementation UIView (CloseKeyboard)

- (void)closeKeyboard {
    [self resignFirstResponderForSubview:self];
}

- (void)resignFirstResponderForSubview:(UIView *)view {
    for ( id v in view.subviews ) {
        if ( [v isKindOfClass:[UIView class]] )
            [self resignFirstResponderForSubview:v];
        
        if ( [v isKindOfClass:[UITextField class]] )
            [v resignFirstResponder];
        
        if ( [v isKindOfClass:[UITextView class]] )
            [v resignFirstResponder];
    }
}

@end

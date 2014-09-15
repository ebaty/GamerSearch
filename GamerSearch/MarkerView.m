//
//  MarkerView.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MarkerView.h"

@interface MarkerView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *snipetLabel;

@end

@implementation MarkerView

#pragma mark - Init methods.
- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 233, 377)];
    if ( self ) {
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _titleLabel = [UILabel new];
    _snipetLabel = [UILabel new];
}

- (void)layout {
    
}

#pragma mark - Setter methods.
- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
}

- (void)setSnipet:(NSString *)snipet {
    _snipet = snipet;
    
    _snipetLabel.text = snipet;
}

@end

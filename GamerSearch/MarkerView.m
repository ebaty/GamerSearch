//
//  MarkerView.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/15.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "MarkerView.h"
#import "MarkerDetailView.h"

@interface MarkerView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *snipetLabel;

@property (nonatomic) MarkerDetailView *detailView;

@end

@implementation MarkerView

#pragma mark - Init methods.
- (id)init {
    self = [super init];
    if ( self ) {
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.clipsToBounds = YES;
        self.backgroundColor = UIColor.whiteColor;
        
        [self initUI];
        [self layout];
    }
    return self;
}

- (void)initUI {
    _titleLabel = [UILabel new];
    _snipetLabel = [UILabel new];
    
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _snipetLabel.font = [UIFont systemFontOfSize:8];

    _snipetLabel.textColor = UIColor.lightGrayColor;
    
    _detailView = [MarkerDetailView new];
}

- (void)layout {
    NSArray *views = @[_titleLabel, _snipetLabel, _detailView];
    for ( UIView *view in views ) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }
    
    NSDictionary *viewsDictionary =
        NSDictionaryOfVariableBindings(_titleLabel, _snipetLabel, _detailView);
    
    NSString *formats[] = {
        @"H:|[_titleLabel(>=100,<=200)]|",
        @"H:|[_snipetLabel(>=100,<=200)]|",
        @"H:|[_detailView(>=100,<=200)]|",
        @"V:|[_titleLabel]-[_snipetLabel]-[_detailView]|"
    };
    
    for ( int i = 0; i < 4; ++i ) {
        NSArray *constraints =
            [NSLayoutConstraint constraintsWithVisualFormat:formats[i]
                                                    options:0
                                                    metrics:nil
                                                      views:viewsDictionary];
        [self addConstraints:constraints];
    }
    

}

- (void)layoutSubviews {
    [super layoutSubviews];
    DDLogVerbose(@"%@", NSStringFromSelector(_cmd));
    DDLogVerbose(@"%@", self);
    DDLogVerbose(@"%@", _titleLabel);
    DDLogVerbose(@"%@", _snipetLabel);
    DDLogVerbose(@"%@", _detailView);
}

- (void)didMoveToSuperview {
    self.frame = self.superview.bounds;
}

#pragma mark - Setter methods.
- (void)setTitle:(NSString *)title {
    _title = title;
    
    _titleLabel.text = title;
    _detailView.gameCetnerName = title;
}

- (void)setSnipet:(NSString *)snipet {
    _snipet = snipet;
    
    _snipetLabel.text = snipet;
}

@end

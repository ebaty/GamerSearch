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
@property (nonatomic) UIButton *catalogButton;

@property (nonatomic) MarkerDetailView *detailView;
@end

@implementation MarkerView

#pragma mark - Init methods.
- (id)init {
    self = [super init];
    if ( self ) {
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
    
    _catalogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_catalogButton setTitle:@"ユーザー表示" forState:UIControlStateNormal];
    
    [_catalogButton addTarget:self
                       action:@selector(pushedCatalogButton:)
             forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _snipetLabel.font = [UIFont systemFontOfSize:12];

    _snipetLabel.textColor = UIColor.grayColor;
    
    _detailView = [MarkerDetailView new];
}

- (void)layout {
    NSArray *views = @[_titleLabel, _snipetLabel, _detailView, _catalogButton];
    for ( UIView *view in views ) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }
    
    NSDictionary *viewsDictionary =
        NSDictionaryOfVariableBindings(_titleLabel, _snipetLabel, _detailView, _catalogButton);
    
    NSString *formats[] = {
        @"H:|-8-[_titleLabel]-[_catalogButton(<=100)]-8-|",
        @"H:|-8-[_snipetLabel]-[_catalogButton(<=100)]-8-|",
        @"H:|[_detailView]|",
        @"V:|-(<=4)-[_titleLabel(<=21)][_snipetLabel(<=21)]-[_detailView(==110)]|",
        @"V:|-(>=10)-[_catalogButton]-(>=10)-[_detailView]"
    };
    
    for ( int i = 0; i < 5; ++i ) {
        NSArray *constraints =
            [NSLayoutConstraint constraintsWithVisualFormat:formats[i]
                                                    options:0
                                                    metrics:nil
                                                      views:viewsDictionary];
        [self addConstraints:constraints];
    }
    

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

#pragma mark - UIEvent methods.
- (void)pushedCatalogButton:(id)sender {
    if ( _delegate && [_delegate respondsToSelector:@selector(didPushedMarkerViewButton)] ) {
        [_delegate didPushedMarkerViewButton];
    }
}
@end

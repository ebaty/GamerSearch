//
//  GameCenterTableView.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/29.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "GameCenterTableView.h"
#import "RegionController.h"

#define kGameCenterCount [RegionController sharedInstance].manager.rangedRegions.count
@interface GameCenterTableView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation GameCenterTableView

- (void)didMoveToSuperview {
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - TableView delegate methods.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int gccount = kGameCenterCount ? kGameCenterCount : 1;
    
    return gccount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    
    if ( kGameCenterCount ) {
        NSArray *gcArray = [RegionController sharedInstance].manager.rangedRegions.allObjects;
        CLRegion *region = gcArray[indexPath.row];
        cell.textLabel.text = region.identifier;
    }else {
        cell.textLabel.text = @"近くにゲームセンターがありません";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

@end

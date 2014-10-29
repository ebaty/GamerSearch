//
//  CheckInViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/28.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "CheckInViewController.h"
#import "RegionController.h"

#define kGameCenterCount [RegionController sharedInstance].nearRegions.count
@interface CheckInViewController ()

@property (nonatomic) NSString *currentLocation;

@end

@implementation CheckInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - TableView delegate.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int gccount = kGameCenterCount ? kGameCenterCount : 1;
    int rows[] = {1, 2, gccount};
    return rows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *section2[] = {@"PSN", @"Xbox Live"};
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = _currentLocation;
            break;
        case 1:
            cell.textLabel.text = section2[indexPath.row];
            break;
        case 2:
            if ( kGameCenterCount ) {
                CLRegion *region = [RegionController sharedInstance].nearRegions.allObjects[indexPath.row];
                cell.textLabel.text = region.identifier;
            }else {
                cell.textLabel.text = @"近くにゲームセンターがありません";
            }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"現在チェックインしている場所", @"オンライン", @"近くのゲームセンター"][section];
}

@end

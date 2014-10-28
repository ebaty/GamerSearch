//
//  CheckInViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/28.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "CheckInViewController.h"
#import "RegionController.h"

#define kGameCenterCount [RegionController sharedInstance].manager.rangedRegions.count
@interface CheckInViewController ()

@end

@implementation CheckInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - TableView delegate.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%d %d", indexPath.section, indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ( indexPath.section != 2 ) {
        return 40.0f;
    }else {
        int gccount = kGameCenterCount ? kGameCenterCount : 1;
        return gccount * 40.0f;
    }
}

@end

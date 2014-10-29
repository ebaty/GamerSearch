//
//  CheckInViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/28.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "CheckInViewController.h"
#import "RegionController.h"

#define kGameCenterCount (int)[RegionController sharedInstance].nearRegions.count
@interface CheckInViewController ()

@end

@implementation CheckInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kReloadCheckInViewController object:nil];
}

- (void)reloadTableView {
    [self.tableView reloadData];
    
    UITableViewCell *topCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [topCell.contentView dismissIndicator];
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
            cell.textLabel.text = [PFUser currentUser][@"gameCenter"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *topCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIAlertView *alert = [UIAlertView new];
    alert.delegate = self;
    alert.cancelButtonIndex = 0;
    [alert addButtonWithTitle:@"キャンセル"];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if ( indexPath.section == 0 ) {
        if ( [currentUser[@"checked_in"] boolValue] ) {
            NSString *nowLocation = currentUser[@"gameCenter"];

            alert.title = [nowLocation stringByAppendingString:@"をチェックアウトしますか？"];
            alert.message = @"他ユーザーにプッシュ通知は行われません";
            [alert bk_addButtonWithTitle:@"チェックアウト" handler:^{
                [topCell.contentView showIndicator];
                [PFCloud callFunctionInBackground:@"check_out" withParameters:@{@"gameCenter":currentUser[@"gameCenter"]} block:^(id object, NSError *error) {
                    if ( !error )
                        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if ( !error )
                                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadCheckInViewController object:self];
                        }];
                }];
            }];
            
            [alert show];
        }
    }else {
        UITableViewCell *selectCell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *gameCenter = selectCell.textLabel.text;
        
        if ( [gameCenter isEqualToString:@"近くにゲームセンターがありません"] ) return;
        
        if ( ![currentUser[@"gameCenter"] isEqualToString:gameCenter] ) {
            alert.title = [gameCenter stringByAppendingString:@"にチェックインしますか？"];
            alert.message = @"チェックインすると他ユーザーに公開されます";
            
            [alert bk_addButtonWithTitle:@"チェックイン" handler:^{
                [topCell.contentView showIndicator];
                [PFCloud callFunctionInBackground:@"check_in" withParameters:@{@"gameCenter":gameCenter} block:^(id object, NSError *error) {
                    if ( !error )
                        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if ( !error )
                                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadCheckInViewController object:self];
                        }];
                }];
            }];
            
            [alert show];
        }
    }
    
}

@end

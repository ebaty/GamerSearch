//
//  SettingTableViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/14.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "SettingTableViewController.h"
#import "SettingTextViewController.h"
#import "IntroViewController.h"

#import "AppDelegate.h"

@implementation SettingTableViewController

- (void)logOut {
    UIAlertView *alert = [UIAlertView new];
    alert.delegate = self;
    alert.title = @"確認";
    alert.message = @"\nログアウトしますか？";
    
    alert.cancelButtonIndex = 0;
    [alert addButtonWithTitle:@"キャンセル"];
    [alert bk_addButtonWithTitle:@"ログアウト" handler:^{
        [PFUser logOut];
        [APP validateAccount];
    }];
    [alert show];
}

#pragma mark - UITableView delegate methods.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 1 && indexPath.row == 0 ) {
        IntroViewController *intro = [IntroViewController new];
        [self presentViewController:intro animated:YES completion:nil];
    }
    if ( indexPath.section == 2 && indexPath.row == 0 ) {
        [self logOut];
    }
}

#pragma mark - Segue methods.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SettingTextViewController *textVC = segue.destinationViewController;
    textVC.title = segue.identifier;
}

@end

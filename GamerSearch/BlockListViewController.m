//
//  BlockListViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/10/06.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "BlockListViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"

@interface BlockListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *blockUserArray;

@end

@implementation BlockListViewController

- (void)viewDidLoad
{
    self.title = @"ブロック";
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"UserCell"];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(pulledRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // ブロックユーザー読み込み
    [self.view showIndicator];
    __block UIView *weak_view = self.view;
    [self setUpBlockUserArray:^{
        [weak_view dismissIndicator];
    }];
}

- (void)setUpBlockUserArray:(void (^)(void))block {
    [PFController queryBlockUser:^(NSArray *blockUser) {
        _blockUserArray = blockUser;
        [self.tableView reloadData];
        if ( block ) block();
    }];
}

- (void)pulledRefreshControl:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    [self setUpBlockUserArray:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark - UITableView delegate methods.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blockUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    cell.userProfileObject = _blockUserArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"UserDetailSegue" sender:_blockUserArray[indexPath.row]];
}

#pragma mark - Segue methods.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"UserDetailSegue"] ) {
        UserDetailViewController *nextViewController = [segue destinationViewController];
        nextViewController.userObject = sender;
    }
}
@end

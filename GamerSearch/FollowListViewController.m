//
//  FollowListViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/20.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "FollowListViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailViewController.h"

@interface FollowListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *followUserArray;

@end

@implementation FollowListViewController

#pragma mark - Set Up methods.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TableViewの初期化
    UINib *cellNib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"UserCell"];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(pulledRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

    // フォローユーザー読み込み
    [self.view showIndicator];
    __block UIView *weak_view = self.view;
    [self setUpFollowUserArray:^{
        [weak_view dismissIndicator];
    }];
}

- (void)setUpFollowUserArray:(void (^)(void))block {
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"followUsers"];
    PFQuery *query = [relation query];
    [query whereKey:@"blockUsers" notEqualTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _followUserArray = objects;
        [self.tableView reloadData];
        
        if ( block ) block();
    }];
}

#pragma mark - UIEvent methods.
- (void)pulledRefreshControl:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    [self setUpFollowUserArray:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark - UITableView delegate methods.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _followUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    cell.userProfileObject = _followUserArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"UserDetailSegue" sender:_followUserArray[indexPath.row]];
}

#pragma mark - Segue methods.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"UserDetailSegue"] ) {
        UserDetailViewController *nextViewController = [segue destinationViewController];
        nextViewController.userObject = sender;
    }
}

@end

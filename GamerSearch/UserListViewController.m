//
//  UserListViewController.m
//  GamerSearch
//
//  Created by Masaki EBATA on 2014/09/18.
//  Copyright (c) 2014年 Masaki EBATA. All rights reserved.
//

#import "UserListViewController.h"
#import "UserTableViewCell.h"

@interface UserListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) NSArray *currentUserArray;

@property (nonatomic) NSArray *userArray;
@property (nonatomic) NSMutableArray *fightGamerArray;
@property (nonatomic) NSMutableArray *musicGamerArray;
@property (nonatomic) NSMutableArray *actionGamerArray;

@end

@implementation UserListViewController

#pragma mark - Set up methods.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentUserArray = [NSArray new];
    
    UINib *cellNib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"UserCell"];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(pulledRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // テーブルの初期化
    self.title = _gameCenterName;
    [self setUpUserArray:YES handler:nil];
}

- (void)setUpUserArray:(BOOL)useCache handler:(void (^)(void))block {
    [PFController queryGameCenterUser:_gameCenterName useCache:useCache handler:^(NSArray *users) {
        _userArray = users;
        [self setUpEachArrayFromUserArray];
        [self setUpCurrentArray:_segmentedControl.selectedSegmentIndex];
        
        if ( block ) block();
    }];
}

- (void)setUpEachArrayFromUserArray {
    _fightGamerArray  = [NSMutableArray new];
    _musicGamerArray  = [NSMutableArray new];
    _actionGamerArray = [NSMutableArray new];
    
    for ( PFObject *user in _userArray ) {
        if ( [user[kFightGamerBoolKey]  boolValue] ) [_fightGamerArray  addObject:user];
        if ( [user[kMusicGamerBoolKey]  boolValue] ) [_musicGamerArray  addObject:user];
        if ( [user[kActionGamerBoolKey] boolValue] ) [_actionGamerArray addObject:user];
    }
}

- (void)setUpCurrentArray:(int)index {
    NSArray *arrayInArray =
    @[
      _userArray,
      _fightGamerArray,
      _musicGamerArray,
      _actionGamerArray,
      ];
    
    _currentUserArray = arrayInArray[index];
    [_tableView reloadData];
}

#pragma mark - UIEvent methods.
- (IBAction)pushedSegmentedControl:(UISegmentedControl *)sender {
    [self setUpCurrentArray:sender.selectedSegmentIndex];
}

- (void)pulledRefreshControl:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    [self setUpUserArray:NO handler:^{
        [refreshControl endRefreshing];
    }];
}

#pragma mark - UITableView delegate methods.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentUserArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    cell.userProfileObject = _userArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

@end

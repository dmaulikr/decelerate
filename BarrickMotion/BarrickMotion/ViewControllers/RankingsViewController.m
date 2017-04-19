//
//  RankingsViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "RankingsViewController.h"
#import "NavigationBarViewController.h"
#import "RankingTableViewCell.h"
#import "BarrickDataManager.h"
#import "BarrickRankingData.h"

@interface RankingsViewController ()

@property (nonatomic, strong) NavigationBarViewController *navigationBarController;

@end

@implementation RankingsViewController

static NSString *cellIdentifier = @"rankingCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the navigation bar
    self.navigationBarController = [[NavigationBarViewController alloc] initWithNibName:@"NavigationBarViewController" bundle:[NSBundle mainBundle]];
    [self.navigationBarView addSubview:self.navigationBarController.view];
    self.navigationBarController.parentController = self;
    
    // Register the custom cell view
    [self.rankingsTableView registerNib:[UINib nibWithNibName:@"RankingTableViewCell"  bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Update the selected tab
    [self.navigationBarController updateSelectedTab];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RankingTableViewCell *cell = [self.rankingsTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSArray *rankingDataArray = [[BarrickDataManager sharedDataManager] rankData];
    if (rankingDataArray) {
        BarrickRankingData *rankingDataObj = [rankingDataArray objectAtIndex:[indexPath row]];
        
        // Update cell with data
        cell.scoreLbl.text = rankingDataObj.score;
        cell.rankLbl.text = rankingDataObj.ranking;
        cell.nameLbl.text = rankingDataObj.name;
        cell.starLbl.text = rankingDataObj.stars;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

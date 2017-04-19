//
//  TripsViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "TripsViewController.h"
#import "NavigationBarViewController.h"
#import "PastTripViewController.h"
#import "TripsTableViewCell.h"
#import "BarrickDataManager.h"
#import "BarrickTripData.h"

@interface TripsViewController ()

@property (nonatomic, strong) NavigationBarViewController *navigationBarController;
@property (nonatomic, strong) PastTripViewController *pastTripViewController;

@end

@implementation TripsViewController

static NSString *cellIdentifier = @"tripCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the navigation bar
    self.navigationBarController = [[NavigationBarViewController alloc] initWithNibName:@"NavigationBarViewController" bundle:[NSBundle mainBundle]];
    [self.navigationBarView addSubview:self.navigationBarController.view];
    self.navigationBarController.parentController = self;
    
    // Register the custom cell view
    [self.tripsTableView registerNib:[UINib nibWithNibName:@"TripsTableViewCell"  bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
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
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TripsTableViewCell *cell = [self.tripsTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSArray *tripDataArray = [[BarrickDataManager sharedDataManager] tripData];
    if (tripDataArray) {
        BarrickTripData *tripDataObj = [tripDataArray objectAtIndex:[indexPath row]];
        
        // Update cell with data
        cell.scoreLbl.text = tripDataObj.score;
        cell.titleLbl.text = tripDataObj.date;
        cell.subtitleLbl.text = [NSString stringWithFormat:@"%@ | %@", tripDataObj.time, tripDataObj.address];
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

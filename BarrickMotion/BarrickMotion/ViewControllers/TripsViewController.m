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
#import "BDDataManager.h"
#import "BDTripData.h"
#import "BDServerDataManager.h"

@interface TripsViewController ()

@property (nonatomic, strong) NavigationBarViewController *navigationBarController;
@property (nonatomic, strong) PastTripViewController *pastTripViewController;

@end

@implementation TripsViewController {
    NSArray *_tripDataArray;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get the trip data from the server for this user
    NSString *driverID = [[BDServerDataManager sharedDataManager] driverID];
    [[BDServerDataManager sharedDataManager] getTripDataForDriverID:driverID withCallback:^(NSArray * _Nullable tripDataArray, NSError * _Nullable error) {
        if (error) {
            _tripDataArray = [[BDDataManager sharedDataManager] tripData];
        } else {
            _tripDataArray = tripDataArray;
        }
        
        // Refresh the view
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tripsTableView reloadData];
        });
    }];
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
    return [_tripDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TripsTableViewCell *cell = [self.tripsTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (_tripDataArray) {
        // Get the trip object to populate the cell
        BDTripData *tripDataObj = [_tripDataArray objectAtIndex:[indexPath row]];
        
        // Update cell with data
        cell.scoreLbl.text = tripDataObj.score;
        cell.titleLbl.text = tripDataObj.date;
        cell.subtitleLbl.text = [NSString stringWithFormat:@"%@ | %@", tripDataObj.time, tripDataObj.routeObj.routeName];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_tripDataArray) {
        // Get the trip object and pass it to the next view
        BDTripData *tripDataObj = [_tripDataArray objectAtIndex:[indexPath row]];
    
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.pastTripViewController = (PastTripViewController *)[sb instantiateViewControllerWithIdentifier:@"PastTripViewController"];
        self.pastTripViewController.tripData = tripDataObj;
        //self.activeTripViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.pastTripViewController animated:YES completion:nil];
    }
}

@end

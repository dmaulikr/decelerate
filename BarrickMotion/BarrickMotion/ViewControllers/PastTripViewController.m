//
//  PastTripViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "PastTripViewController.h"
#import "BDServerDataManager.h"

@interface PastTripViewController ()

@end

@implementation PastTripViewController {
    NSArray *_locDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the location data from the server
    [[BDServerDataManager sharedDataManager] getLocationDataForTripID:_tripData.tripID forRouteID:_tripData.routeID withCallback:^(NSArray * _Nullable locDataArray, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Unable to retrieve location data due to error: %@", error);
        } else {
            // Setup the map
            dispatch_async(dispatch_get_main_queue(), ^{
                _locDataArray = locDataArray;
                
                // Create the annotated map
                [self.mapView setupMapViewWithLocData:locDataArray];
            });
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // Refresh the map
    [self.mapView updateMapView];
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnPressed:(id)sender {
    NSLog(@"backBtnPressed called.");
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_locDataArray count];
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


@end

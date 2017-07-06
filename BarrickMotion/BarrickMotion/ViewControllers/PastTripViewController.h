//
//  PastTripViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDAnnotatedMapView.h"
#import "BDTripData.h"

/**
 * View and controller for displaying route and violations of a trip that has already been recorded
 */
@interface PastTripViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet BDAnnotatedMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BDTripData *tripData;

// Return to previous screen
- (IBAction)backBtnPressed:(id)sender;

@end

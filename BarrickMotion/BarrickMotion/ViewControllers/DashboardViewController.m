//
//  DashboardViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "DashboardViewController.h"
#import "NavigationBarViewController.h"
#import "ActiveTripViewController.h"

@interface DashboardViewController ()

@property (nonatomic, strong) NavigationBarViewController *navigationBarController;
@property (nonatomic, strong) ActiveTripViewController *activeTripViewController;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the navigation bar
    self.navigationBarController = [[NavigationBarViewController alloc] initWithNibName:@"NavigationBarViewController" bundle:[NSBundle mainBundle]];
    [self.navigationBarView addSubview:self.navigationBarController.view];
    self.navigationBarController.parentController = self;
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

- (IBAction)startTripBtnPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.activeTripViewController = (ActiveTripViewController *)[sb instantiateViewControllerWithIdentifier:@"ActiveTripViewController"];
    //self.activeTripViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.activeTripViewController animated:YES completion:nil];
}
@end

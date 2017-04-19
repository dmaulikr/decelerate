//
//  NavigationBarViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "NavigationBarViewController.h"
#import "AppDelegate.h"
#import "ColorPallete.h"

typedef NS_ENUM(NSInteger, BarrickTabIndex) {
    BarrickTabIndexDashboard = 0,
    BarrickTabIndexTrips,
    BarrickTabIndexRankings
};

@interface NavigationBarViewController ()

@end

@implementation NavigationBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the selected tab
    [self updateSelectedTab];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSelectedTab {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger activeTabIndex = [appDel activeTabIndex];
    
    switch (activeTabIndex) {
        case BarrickTabIndexDashboard: {
            [self.dashboardBtn setTitleColor:[ColorPallete blueTextBold] forState:UIControlStateNormal];
            self.dashboardUnderlineView.hidden = NO;
            break;
        }
        case BarrickTabIndexTrips: {
            [self.tripsBtn setTitleColor:[ColorPallete blueTextBold] forState:UIControlStateNormal];
            self.tripsUnderlineView.hidden = NO;
            break;
        }
        case BarrickTabIndexRankings: {
            [self.rankingsBtn setTitleColor:[ColorPallete blueTextBold] forState:UIControlStateNormal];
            self.rankingsUnderlineView.hidden = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Navigation

- (IBAction)dashboardBtnPressed:(id)sender {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDel.activeTabIndex != BarrickTabIndexDashboard) {
        [appDel changeActiveTab:BarrickTabIndexDashboard];
    }
}

- (IBAction)tripsBtnPressed:(id)sender {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDel.activeTabIndex != BarrickTabIndexTrips) {
        [appDel changeActiveTab:BarrickTabIndexTrips];
    }
}

- (IBAction)rankingsBtnPressed:(id)sender {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDel.activeTabIndex != BarrickTabIndexRankings) {
        [appDel changeActiveTab:BarrickTabIndexRankings];
    }
}
@end

//
//  NavigationBarViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBarViewController : UIViewController

@property (nonatomic, strong) UIViewController *parentController;

@property (strong, nonatomic) IBOutlet UIButton *dashboardBtn;
@property (strong, nonatomic) IBOutlet UIButton *tripsBtn;
@property (strong, nonatomic) IBOutlet UIButton *rankingsBtn;

@property (strong, nonatomic) IBOutlet UIView *dashboardUnderlineView;
@property (strong, nonatomic) IBOutlet UIView *tripsUnderlineView;
@property (strong, nonatomic) IBOutlet UIView *rankingsUnderlineView;

- (IBAction)dashboardBtnPressed:(id)sender;
- (IBAction)tripsBtnPressed:(id)sender;
- (IBAction)rankingsBtnPressed:(id)sender;

- (void)updateSelectedTab;

@end

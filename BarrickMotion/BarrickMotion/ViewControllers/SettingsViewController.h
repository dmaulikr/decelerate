//
//  SettingsViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * View and controller for user/admin Settings.
 * This entire thing needs to be overhauled. Right now it is just for our testing
 */
@interface SettingsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *routeIDField;
@property (strong, nonatomic) IBOutlet UITextField *driverIDField;
@property (strong, nonatomic) IBOutlet UITextField *routeNameField;
@property (strong, nonatomic) IBOutlet UISwitch *isMasterSwitch;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceGyrox;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceGyroY;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceGyroZ;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceAccX;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceAccY;
@property (strong, nonatomic) IBOutlet UITextField *segmentToleranceAccZ;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceGyroX;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceGyroY;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceGyroZ;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceAccX;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceAccY;
@property (strong, nonatomic) IBOutlet UITextField *violationToleranceAccZ;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

// Update master data recording status
- (IBAction)isMasterSwitchValueChanged:(id)sender;

// Return to previous screen
- (IBAction)backButtonPressed:(id)sender;

@end

//
//  SettingsViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "SettingsViewController.h"
#import "BDServerDataManager.h"
#import "BDMotionManager.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    UITextField *_currentField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
    // Load the current values from the appropriate manager
    self.driverIDField.text = [[BDServerDataManager sharedDataManager] driverID];
    self.routeIDField.text = [[BDServerDataManager sharedDataManager] routeID];
    self.routeNameField.text = [[BDServerDataManager sharedDataManager] routeName];
    [self.isMasterSwitch setOn:[[BDServerDataManager sharedDataManager] isMasterRecording]];
    
    self.segmentToleranceGyrox.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeGyroX] stringValue];
    self.segmentToleranceGyroY.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeGyroY] stringValue];
    self.segmentToleranceGyroZ.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeGyroZ] stringValue];
    self.segmentToleranceAccX.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeAccX] stringValue];
    self.segmentToleranceAccY.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeAccY] stringValue];
    self.segmentToleranceAccZ.text = [[[BDMotionManager sharedMotionManager] getBaselineToleranceForSensorType:BDMotionManagerSensorTypeAccZ] stringValue];
    
    self.violationToleranceGyroX.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeGyroX] stringValue];
    self.violationToleranceGyroY.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeGyroY] stringValue];
    self.violationToleranceGyroZ.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeGyroZ] stringValue];
    self.violationToleranceAccX.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeAccX] stringValue];
    self.violationToleranceAccY.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeAccY] stringValue];
    self.violationToleranceAccZ.text = [[[BDMotionManager sharedMotionManager] getViolationToleranceForSensorType:BDMotionManagerSensorTypeAccZ] stringValue];
    
    // Update the scrollView layout
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterKeyboardNotifications];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - IBActions

- (IBAction)isMasterSwitchValueChanged:(id)sender {
    [[BDServerDataManager sharedDataManager] setIsMasterRecording:self.isMasterSwitch.isOn];
}

- (IBAction)backButtonPressed:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard States

// Call in viewWillAppear:
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Call in viewWillDisappear:
- (void)unregisterKeyboardNotifications {
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _currentField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _currentField.frame.origin.y-kbSize.height);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _currentField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // Update all values in the appropriate manager
    [[BDServerDataManager sharedDataManager] setRouteID:self.routeIDField.text];
    [[BDServerDataManager sharedDataManager] setDriverID:self.driverIDField.text];
    [[BDServerDataManager sharedDataManager] setRouteName:self.routeNameField.text];

    float toleranceValue;
    if (textField == self.segmentToleranceGyrox) {
        toleranceValue = [self.segmentToleranceGyrox.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroX];
    } else if (textField == self.segmentToleranceGyroY) {
        toleranceValue = [self.segmentToleranceGyroY.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroY];
    } else if (textField == self.segmentToleranceGyroZ) {
        toleranceValue = [self.segmentToleranceGyroZ.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroZ];
    } else if (textField == self.segmentToleranceAccX) {
        toleranceValue = [self.segmentToleranceAccX.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccX];
    } else if (textField == self.segmentToleranceAccY) {
        toleranceValue = [self.segmentToleranceAccY.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccY];
    } else if (textField == self.segmentToleranceAccZ) {
        toleranceValue = [self.segmentToleranceAccZ.text floatValue];
        [[BDMotionManager sharedMotionManager] setBaselineTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccZ];
    } else if (textField == self.violationToleranceGyroX) {
        toleranceValue = [self.violationToleranceGyroX.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroX];
    } else if (textField == self.violationToleranceGyroY) {
        toleranceValue = [self.violationToleranceGyroY.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroY];
    } else if (textField == self.violationToleranceGyroZ) {
        toleranceValue = [self.violationToleranceGyroZ.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeGyroZ];
    } else if (textField == self.violationToleranceAccX) {
        toleranceValue = [self.violationToleranceAccX.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccX];
    } else if (textField == self.violationToleranceAccY) {
        toleranceValue = [self.violationToleranceAccY.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccY];
    } else if (textField == self.violationToleranceAccZ) {
        toleranceValue = [self.violationToleranceAccZ.text floatValue];
        [[BDMotionManager sharedMotionManager] setViolationTolerance:toleranceValue forSensorType:BDMotionManagerSensorTypeAccZ];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Hide the keyboard
    return [textField resignFirstResponder];
}

@end

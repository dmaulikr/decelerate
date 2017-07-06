//
//  ViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "ActiveTripViewController.h"
#import "AppDelegate.h"
#import "BDDataPacket.h"
#import "ColorPallete.h"
#include <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

static const NSInteger kStartingTripScore = 100;
static const NSInteger kViolationDisplaySeconds = 3;


@interface ActiveTripViewController ()

@end

@implementation ActiveTripViewController {
    CAShapeLayer *_circleLayer;
    BOOL _alertingDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _alertingDriver = NO;
    
    // Draw the circle
    _circleLayer = [CAShapeLayer layer];
    [_circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 20, self.circleBorderView.frame.size.width-40, self.circleBorderView.frame.size.height-40)] CGPath]];
    [self.circleBorderView.layer addSublayer:_circleLayer];
    [_circleLayer setStrokeColor:[[ColorPallete goodGreen] CGColor]];
    [_circleLayer setLineWidth:10];
    [_circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    self.scoreLbl.text = [NSString stringWithFormat:@"%ld", (long)kStartingTripScore];
    
    // Start recording driving data when view is showen
    [BDMotionManager sharedMotionManager].delegate = self;
    [[BDMotionManager sharedMotionManager] startMeasurements];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // TODO: Only update the trip data if FINISHED is pressed?
    // Stop recording driving data when view is closed
    [[BDMotionManager sharedMotionManager] stopMeasurements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods


#pragma mark - IBActions

- (IBAction)backBtnPressed:(id)sender {
    NSLog(@"backBtnPressed called.");
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tripFinishedBtnPressed:(id)sender {
    NSLog(@"tripFinishedBtnPressed called.");
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BDMotionManagerDelegate

- (void)detetectedMotionViolation:(BDMotionManagerViolationType)violationType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_alertingDriver == NO) {
            _alertingDriver = YES;
            
            // Update UI
            [_circleLayer setStrokeColor:[[ColorPallete badRed] CGColor]];
            [self.statusLbl setTextColor:[ColorPallete badRed]];
            self.statusLbl.text = ViolationStringFromBDMotionManagerViolationType(violationType);
            
            // Make beeping sound
            AudioServicesPlaySystemSound(1050);
            
            // Decrease the score counter
            NSInteger currentScore = [self.scoreLbl.text integerValue]-1;
            self.scoreLbl.text = [NSString stringWithFormat:@"%d",currentScore];
            
            // Delay returning the UI colors to normal for kViolationDisplaySeconds seconds.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kViolationDisplaySeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_circleLayer setStrokeColor:[[ColorPallete goodGreen] CGColor]];
                [self.statusLbl setTextColor:[ColorPallete goodGreen]];
                self.statusLbl.text = ViolationStringFromBDMotionManagerViolationType(BDMotionManagerViolationTypeNone);
                _alertingDriver = NO;
            });
        }
    });
}

- (void)masterTripDataDownloadError:(NSError *)error {
    
    // Show the alert on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [error description];
        if (NSClassFromString(@"UIAlertController")) {
            // iOS 8+
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    });
}

@end

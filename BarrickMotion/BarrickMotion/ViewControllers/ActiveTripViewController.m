//
//  ViewController.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "ActiveTripViewController.h"
#import "AppDelegate.h"
#import "DataPacket.h"
#import "ColorPallete.h"
#import <CoreMotion/CoreMotion.h>
#include <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

#define kServerUrl @"http://kevinjameshunt.com/barrick"

static const NSTimeInterval accelerometerMin = 0.5; // 500 milliseconds
static const float zeroGraphYOffset = 120.0;
static const NSInteger kStartingTripScore = 79;
static const NSInteger kArrayCapacity = 20;
static const float kValueDifference = 4.0;

@interface ActiveTripViewController ()

@end

@implementation ActiveTripViewController {
    UIView *_graphView;
    NSMutableArray *_xAccVals;
    NSMutableArray *_yAccVals;
    NSMutableArray *_zAccVals;
    
    CAShapeLayer *_xLayer;
    CAShapeLayer *_yLayer;
    CAShapeLayer *_zLayer;
    DataPacket *_currentPacket;
    CAShapeLayer *_circleLayer;
    BOOL _started;
    BOOL _alertingDriver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _alertingDriver = NO;
    
    // Setup arrays
    _currentPacket = [[DataPacket alloc] init];
    _xAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
    _yAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
    _zAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
    
    _graphView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 200)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //  requestWhenInUseAuthorization is only available on iOS 8
    //  Make sure you also modify the application info.plist to include a NSLocationWhenInUseUsageDescription string
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Draw the circle
    _circleLayer = [CAShapeLayer layer];
    [_circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(20, 20, self.circleBorderView.frame.size.width-40, self.circleBorderView.frame.size.height-40)] CGPath]];
    [self.circleBorderView.layer addSublayer:_circleLayer];
    [_circleLayer setStrokeColor:[[ColorPallete goodGreen] CGColor]];
    [_circleLayer setLineWidth:10];
    [_circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    self.scoreLbl.text = [NSString stringWithFormat:@"%ld", kStartingTripScore];
    
    [self startMeasurements];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopMeasurements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods

- (void)startMeasurements {
    if (!_started) {
        _currentPacket.driverID = @"TestDriver1";
        _currentPacket.sensorID = @"sensor1";
        _currentPacket.load = @"1000";
        
        [self.locationManager startUpdatingLocation];
        
        // Create a CMMotionManager
        CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
        ActiveTripViewController * __weak weakSelf = self;
        
        // Check whether the accelerometer is available
        if ([mManager isAccelerometerAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setAccelerometerUpdateInterval:accelerometerMin];
            [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
//                weakSelf.logView.text = [NSString stringWithFormat:@"%@\nX: %f Y:%f Z:%f", weakSelf.logView.text, accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];
//                
//                [weakSelf.logView scrollRectToVisible:CGRectMake(weakSelf.logView.contentSize.width - 1,weakSelf.logView.contentSize.height - 1, 1, 1) animated:YES];
                
                _currentPacket.accelerometerData = accelerometerData;
                [weakSelf checkForSpike];
                
                if ([_xAccVals count] == kArrayCapacity) {
                    [_xAccVals removeObjectAtIndex:0];
                }
                [_xAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.x]];
                
                if ([_yAccVals count] == kArrayCapacity) {
                    [_yAccVals removeObjectAtIndex:0];
                }
                [_yAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.y]];
                
                if ([_zAccVals count] == kArrayCapacity) {
                    [_zAccVals removeObjectAtIndex:0];
                }
                [_zAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.z]];
                
//                [weakSelf drawX];
//                [weakSelf drawY];
//                [weakSelf drawZ];

                [weakSelf processDataPacket];
            }];
        }
        
        // Check whether the gyroscope is available
        if ([mManager isGyroAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setGyroUpdateInterval:accelerometerMin];
            [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
                _currentPacket.gyroData = gyroData;
                [weakSelf processDataPacket];
            }];
        }
        
        // Check whether the magnetometer is available
        if ([mManager isMagnetometerAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setMagnetometerUpdateInterval:accelerometerMin];
            [mManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                _currentPacket.magData = magnetometerData;
                [weakSelf processDataPacket];
            }];
        }
        
        _started = YES;
//        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}
- (void)stopMeasurements {
    if (_started) {
        [self.locationManager stopUpdatingLocation];
        
        CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
        if ([mManager isAccelerometerActive] == YES) {
            [mManager stopAccelerometerUpdates];
        }
        if ([mManager isGyroActive] == YES) {
            [mManager stopGyroUpdates];
        }
        if ([mManager isMagnetometerActive] == YES) {
            [mManager stopMagnetometerUpdates];
        }
        
        _started = NO;
//        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)checkForSpike {
    float xSum = 0.0, ySum = 0.0, zSum = 0.0;
    float xAverage, yAverage, zAverage;
    
    if (_xAccVals.count == kArrayCapacity) {
        for (NSNumber *xVal in _xAccVals) {
            xSum += [xVal floatValue];
        }
        xAverage = xSum / kArrayCapacity;
        
        // If the new value is 20% greater than the average from the previous data, show a spike.
        if (ABS(xAverage*kValueDifference) < ABS(_currentPacket.accelerometerData.acceleration.x)) {
            NSLog(@"Spike detected on accelleration X-axis.");
            [self showUnsafeDriving];
            return;
        }
    }
    
    if (_yAccVals.count == kArrayCapacity) {
        for (NSNumber *yVal in _yAccVals) {
            ySum += [yVal floatValue];
        }
        yAverage = ySum / kArrayCapacity;
        
        // If the new value is 20% greater than the average from the previous data, show a spike.
        if (ABS(yAverage*kValueDifference) < ABS(_currentPacket.accelerometerData.acceleration.y)) {
            NSLog(@"Spike detected on accelleration Y-axis.");
            [self showUnsafeDriving];
            return;
        }
    }
    
    if (_zAccVals.count == kArrayCapacity) {
        for (NSNumber *zVal in _zAccVals) {
            zSum += [zVal floatValue];
        }
        zAverage = zSum / kArrayCapacity;
        
        // If the new value is 20% greater than the average from the previous data, show a spike.
        if (ABS(zAverage*kValueDifference) < ABS(_currentPacket.accelerometerData.acceleration.z)) {
            NSLog(@"Spike detected on accelleration Z-axis.");
            [self showUnsafeDriving];
            return;
        }
    }
}

- (void)showUnsafeDriving {
    
    if (_alertingDriver == NO) {
        _alertingDriver = YES;
        
        // Update UI
        [_circleLayer setStrokeColor:[[ColorPallete badRed] CGColor]];
        [self.statusLbl setTextColor:[ColorPallete badRed]];
        self.statusLbl.text = @"TURN SLOWER";
        
        // Make beeping sound
        AudioServicesPlaySystemSound(1050);
        
        // Decrease the score counter
        NSInteger currentScore = [self.scoreLbl.text integerValue];
        self.scoreLbl.text = [NSString stringWithFormat:@"%ld",(currentScore-1)];
        
        // Delay returning the UI colors to normal for 5 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_circleLayer setStrokeColor:[[ColorPallete goodGreen] CGColor]];
            [self.statusLbl setTextColor:[ColorPallete goodGreen]];
            self.statusLbl.text = @"GOOD SPEED";
            _alertingDriver = NO;
        });
    }
}

- (void)processDataPacket {
    if (_currentPacket.location != nil &&
        _currentPacket.accelerometerData != nil &&
        _currentPacket.gyroData != nil &&
        _currentPacket.magData != nil &&
        _currentPacket.driverID != nil &&
        _currentPacket.sensorID != nil) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
        
        // Send the data to the server
        NSString *urlString = [[NSString alloc] initWithFormat:@"driverID=%@",_currentPacket.driverID];
        urlString = [urlString stringByAppendingFormat:@"&sensorID=%@",_currentPacket.sensorID];
        urlString = [urlString stringByAppendingFormat:@"&load=%@",_currentPacket.load];
        urlString = [urlString stringByAppendingFormat:@"&longitude=%f",_currentPacket.location.coordinate.longitude];
        urlString = [urlString stringByAppendingFormat:@"&latitude=%f",_currentPacket.location.coordinate.latitude];
        urlString = [urlString stringByAppendingFormat:@"&accX=%f",_currentPacket.accelerometerData.acceleration.x];
        urlString = [urlString stringByAppendingFormat:@"&accY=%f",_currentPacket.accelerometerData.acceleration.y];
        urlString = [urlString stringByAppendingFormat:@"&accZ=%f",_currentPacket.accelerometerData.acceleration.z];
        urlString = [urlString stringByAppendingFormat:@"&gyroX=%f",_currentPacket.gyroData.rotationRate.x];
        urlString = [urlString stringByAppendingFormat:@"&gyroY=%f",_currentPacket.gyroData.rotationRate.y];
        urlString = [urlString stringByAppendingFormat:@"&gyroZ=%f",_currentPacket.gyroData.rotationRate.z];
        urlString = [urlString stringByAppendingFormat:@"&magX=%f",_currentPacket.magData.magneticField.x];
        urlString = [urlString stringByAppendingFormat:@"&magY=%f",_currentPacket.magData.magneticField.y];
        urlString = [urlString stringByAppendingFormat:@"&magZ=%f",_currentPacket.magData.magneticField.z];
        urlString = [urlString stringByAppendingFormat:@"&timestamp=%@",timestamp];
        
        // Add escape characters
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Convert to data
        NSData *myRequestData = [ NSData dataWithBytes: [ urlString UTF8String ] length: [ urlString length ] ];
        
        NSLog(@"%@",urlString);
        
        // Create request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"/submitBarrickLoc.php"]]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: myRequestData];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        
        // Send request
        NSHTTPURLResponse* response = nil;
        NSError* error = [[NSError alloc] init];
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error ];
        
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"Server response: \n%@", returnString);
        
        // Clear the packet
        _currentPacket.accelerometerData = nil;
        _currentPacket.gyroData = nil;
        _currentPacket.magData = nil;
        
    } else {
        NSLog(@"Packet not ready to send");
    }
}

- (void)drawX {
    float lastXPos = 0.0;
    float lastXVal = 0.0;
    
    [_xLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastXPos, zeroGraphYOffset+(lastXVal*10))];
    
    for (int i=0; i< [_xAccVals count]; i++) {
        float xVal = [[_xAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastXPos+5.0f, zeroGraphYOffset+(xVal*10))];
        lastXPos +=5;
        lastXVal = xVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _xLayer = shapeLayer;
}

- (void)drawZ {
    float lastZPos = 0.0;
    float lastZVal = 0.0;
    
    [_zLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastZPos, zeroGraphYOffset+(lastZVal*10))];
    
    for (int i=0; i< [_zAccVals count]; i++) {
        float zVal = [[_zAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastZPos+5.0f, zeroGraphYOffset+(zVal*10))];
        lastZPos +=5;
        lastZVal = zVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _zLayer = shapeLayer;
}

- (void)drawY {
    float lastYPos = 0.0;
    float lastYVal = 0.0;
    
    [_yLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastYPos, zeroGraphYOffset+(lastYVal*10))];
    
    for (int i=0; i< [_yAccVals count]; i++) {
        float yVal = [[_yAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastYPos+5.0f, zeroGraphYOffset+(yVal*10))];
        lastYPos +=5;
        lastYVal = yVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor greenColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _yLayer = shapeLayer;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    _currentPacket.location = location;
}

#pragma mark - IBActions

- (IBAction)backBtnPressed:(id)sender {
    NSLog(@"backBtnPressed called.");
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tripFinishedBtnPressed:(id)sender {
    NSLog(@"tripFinishedBtnPressed called.");
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end

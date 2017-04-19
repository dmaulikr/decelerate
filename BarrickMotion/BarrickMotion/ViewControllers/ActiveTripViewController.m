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
#import <CoreMotion/CoreMotion.h>

#define kServerUrl @"http://kevinjameshunt.com/barrick"

static const NSTimeInterval accelerometerMin = 0.5; // 500 milliseconds
static const float zeroGraphYOffset = 120.0;

@interface ActiveTripViewController ()

@end

@implementation ActiveTripViewController {
    UIView *_graphView;
    NSMutableArray *_xAccVals;
    NSMutableArray *_yAccVals;
    NSMutableArray *_zAccVals;
    NSInteger _arrayCapacity;
    CAShapeLayer *_xLayer;
    CAShapeLayer *_yLayer;
    CAShapeLayer *_zLayer;
    DataPacket *_currentPacket;
    BOOL _started;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _currentPacket = [[DataPacket alloc] init];
    _arrayCapacity = (self.view.frame.size.width)/5;
    _xAccVals = [[NSMutableArray alloc] initWithCapacity:_arrayCapacity];
    _yAccVals = [[NSMutableArray alloc] initWithCapacity:_arrayCapacity];
    _zAccVals = [[NSMutableArray alloc] initWithCapacity:_arrayCapacity];
    
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
    
}

- (IBAction)didTapStartStop:(id)sender {
    
    if (!_started) {
        _currentPacket.driverID = self.driverId.text;
        _currentPacket.sensorID = self.sensorId.text;
        _currentPacket.load = self.load.text;
        
        [self.locationManager startUpdatingLocation];
        
        // Create a CMMotionManager
        CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
        ActiveTripViewController * __weak weakSelf = self;
        
        // Check whether the accelerometer is available
        if ([mManager isAccelerometerAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setAccelerometerUpdateInterval:accelerometerMin];
            [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                
                weakSelf.logView.text = [NSString stringWithFormat:@"%@\nX: %f Y:%f Z:%f", weakSelf.logView.text, accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z];
                
                [weakSelf.logView scrollRectToVisible:CGRectMake(weakSelf.logView.contentSize.width - 1,weakSelf.logView.contentSize.height - 1, 1, 1) animated:YES];
                
                if ([_xAccVals count] == _arrayCapacity) {
                    [_xAccVals removeObjectAtIndex:0];
                }
                [_xAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.x]];
                
                if ([_yAccVals count] == _arrayCapacity) {
                    [_yAccVals removeObjectAtIndex:0];
                }
                [_yAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.y]];
                
                if ([_zAccVals count] == _arrayCapacity) {
                    [_zAccVals removeObjectAtIndex:0];
                }
                [_zAccVals addObject:[NSNumber numberWithFloat:accelerometerData.acceleration.z]];
                
                [weakSelf drawX];
                [weakSelf drawY];
                [weakSelf drawZ];
                
                _currentPacket.accelerometerData = accelerometerData;
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
        
        // Check whether the gyroscope is available
        if ([mManager isMagnetometerAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setMagnetometerUpdateInterval:accelerometerMin];
            [mManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
                _currentPacket.magData = magnetometerData;
                [weakSelf processDataPacket];
            }];
        }
        
        _started = YES;
        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.locationManager stopUpdatingLocation];
        
        CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
        if ([mManager isAccelerometerActive] == YES) {
            [mManager stopAccelerometerUpdates];
        }
        if ([mManager isGyroAvailable] == YES) {
            [mManager stopGyroUpdates];
        }
        
        _started = NO;
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
    
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    if ([mManager isAccelerometerActive] == YES) {
        [mManager stopAccelerometerUpdates];
    }
    if ([mManager isGyroAvailable] == YES) {
        [mManager stopGyroUpdates];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    
    if (textField == self.driverId) {
        _currentPacket.driverID = textField.text;
    }
    if (textField == self.sensorId) {
        _currentPacket.sensorID = textField.text;
    }
    if (textField == self.load) {
        _currentPacket.load = textField.text;
    }
    
    return YES;
}

@end

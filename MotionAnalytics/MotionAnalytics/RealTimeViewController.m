//
//  FirstViewController.m
//  MotionAnalytics
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "RealTimeViewController.h"
#import "DataObject3D.h"

#define kServerUrl @"http://kevinjameshunt.com/barrick"
#define kServeralIntervalTime 4

static const NSTimeInterval changeThreshold = .10; // Percentage of change
static const float zeroGraphAccYOffset = 500;
static const float zeroGraphGyroYOffset = 740.0;
static const float zeroGraphSpeedYOffset = 940.0;

@interface RealTimeViewController ()

@end

@implementation RealTimeViewController {
    NSDate *_lastTimestamp;
    NSTimer *_timer;
    NSMutableArray *_dataStream;
    NSInteger _arrayCapacity;
    
    NSMutableArray *_accX;
    NSMutableArray *_accY;
    NSMutableArray *_accZ;
    NSMutableArray *_gyroX;
    NSMutableArray *_gyroY;
    NSMutableArray *_gyroZ;
    NSMutableArray *_speed;
    
    CAShapeLayer *_accXLayer;
    CAShapeLayer *_accYLayer;
    CAShapeLayer *_accZLayer;
    CAShapeLayer *_gyroXLayer;
    CAShapeLayer *_gyroYLayer;
    CAShapeLayer *_gyroZLayer;
    CAShapeLayer *_speedLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _accX = [[NSMutableArray alloc] init];
    _accY = [[NSMutableArray alloc] init];
    _accZ = [[NSMutableArray alloc] init];
    _gyroX = [[NSMutableArray alloc] init];
    _gyroY = [[NSMutableArray alloc] init];
    _gyroZ = [[NSMutableArray alloc] init];
    _speed = [[NSMutableArray alloc] init];
    
    // Get data from one hour ago
    _lastTimestamp = [[NSDate date] dateByAddingTimeInterval:-30]; //Retrieve everything from 1/4 an hour ago when first loaded
    _arrayCapacity = (self.view.frame.size.width)/5;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //  requestWhenInUseAuthorization is only available on iOS 8
    //  Make sure you also modify the application info.plist to include a NSLocationWhenInUseUsageDescription string
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
        
    }
    
    [self.locationManager startUpdatingLocation];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    //View Area
    MKCoordinateRegion region = self.mapView.region;
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.001f;
    region.span.latitudeDelta = 0.001f;
    [self.mapView setRegion:region animated:YES];
    
    [self retrieveServerData];
    
    [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
    [self invalidateTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimer {
    [self invalidateTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kServeralIntervalTime target:self selector:@selector(retrieveServerData) userInfo:nil repeats:YES];
}

- (void)invalidateTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)retrieveServerData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *timestamp = [dateFormatter stringFromDate:_lastTimestamp];
    
    // Send the data to the server
    NSString *urlString = [[NSString alloc] initWithFormat:@"driverID=%@",@"JohnDriver"];
    urlString = [urlString stringByAppendingFormat:@"&timestamp=%@",timestamp];
    
    // Add escape characters
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // Convert to data
    NSData *myRequestData = [ NSData dataWithBytes: [ urlString UTF8String ] length: [ urlString length ] ];
    
    NSLog(@"%@",urlString);
    
    // Create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"/getBarrickLoc.php"]]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    // Send request
    NSHTTPURLResponse* response = nil;
    NSError* error;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error ];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Server response: \n%@", returnString);
    
    if (returnData) {
        NSError* jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&jsonError];
        
        if (!jsonError && jsonDict) {
            NSArray *newData = [jsonDict objectForKey:@"movementData"];
            if (newData) {
                NSMutableArray *sensorLData = [[NSMutableArray alloc] init];
                NSMutableArray *sensorRData = [[NSMutableArray alloc] init];
                
                // loop through all data and pair it up
                for (NSDictionary *dataDict in newData) {
                    if ([[dataDict objectForKey:@"sensorID"] isEqualToString:@"SensorL"]) {
                        [sensorLData addObject:dataDict];
                    } else if ([[dataDict objectForKey:@"sensorID"] isEqualToString:@"SensorR"]) {
                        [sensorRData addObject:dataDict];
                    }
                }
                
                // Loop through the left sensors, then the right to find matching timestamps
                for (NSDictionary *lData in sensorLData) {
                    NSDate *lTimestamp = [dateFormatter dateFromString:[lData objectForKey:@"timestamp"]];
                    for (NSDictionary *rData in sensorRData) {
                        NSDate *rTimestamp = [dateFormatter dateFromString:[rData objectForKey:@"timestamp"]];
                        NSTimeInterval secondsBetween = [lTimestamp timeIntervalSinceDate:rTimestamp];
                        if (secondsBetween >= -0.5 || secondsBetween <= 0.5) {
                            DataObject3D *dataObj = [[DataObject3D alloc] init];
                            dataObj.timestamp = lTimestamp;
                            dataObj.sensorLeft = lData;
                            dataObj.sensorRight = rData;
                            
                            float accXVal = 5*([[lData objectForKey:@"accX"] floatValue]+[[rData objectForKey:@"accX"] floatValue])/2; // Take the average
                            if ([_accX count] == _arrayCapacity) {
                                [_accX removeObjectAtIndex:0];
                            }
                            [_accX addObject:[NSNumber numberWithFloat:accXVal]];
                            dataObj.averageAccX = accXVal;
                            
                            float accYVal = 5*([[lData objectForKey:@"accY"] floatValue]+[[rData objectForKey:@"accY"] floatValue])/2; // Take the average
                            if ([_accY count] == _arrayCapacity) {
                                [_accY removeObjectAtIndex:0];
                            }
                            [_accY addObject:[NSNumber numberWithFloat:accYVal]];
                            dataObj.averageAccY = accYVal;
                            
                            float accZVal = 5*([[lData objectForKey:@"accZ"] floatValue]+[[rData objectForKey:@"accZ"] floatValue])/2; // Take the average
                            if ([_accZ count] == _arrayCapacity) {
                                [_accZ removeObjectAtIndex:0];
                            }
                            [_accZ addObject:[NSNumber numberWithFloat:accZVal]];
                            dataObj.averageAccZ = accZVal;
                            
                            float gyroXVal = ([[lData objectForKey:@"gyroX"] floatValue]+[[rData objectForKey:@"gyroX"] floatValue])/2; // Take the average
                            if ([_gyroX count] == _arrayCapacity) {
                                [_gyroX removeObjectAtIndex:0];
                            }
                            [_gyroX addObject:[NSNumber numberWithFloat:gyroXVal]];
                            dataObj.averageGyroX = gyroXVal;
                            
                            float gyroYVal = ([[lData objectForKey:@"gyroY"] floatValue]+[[rData objectForKey:@"gyroY"] floatValue])/2; // Take the average
                            if ([_gyroY count] == _arrayCapacity) {
                                [_gyroY removeObjectAtIndex:0];
                            }
                            [_gyroY addObject:[NSNumber numberWithFloat:gyroYVal]];
                            dataObj.averageGyroY = gyroYVal;
                            
                            float gyroZVal = ([[lData objectForKey:@"gyroZ"] floatValue]+[[rData objectForKey:@"gyroZ"] floatValue])/2; // Take the average
                            if ([_gyroZ count] == _arrayCapacity) {
                                [_gyroZ removeObjectAtIndex:0];
                            }
                            [_gyroZ addObject:[NSNumber numberWithFloat:gyroZVal]];
                            dataObj.averageGyroZ = gyroZVal;
                            
                            float speedVal = ([[lData objectForKey:@"magX"] floatValue]+[[rData objectForKey:@"magX"] floatValue])/2; // Take the average
                            if (speedVal > 1000) {
                                speedVal = 100;
                            } else {
                                speedVal = speedVal / 5;
                            }
                            
                            if ([_speed count] == _arrayCapacity) {
                                [_speed removeObjectAtIndex:0];
                            }
                            [_speed addObject:[NSNumber numberWithFloat:speedVal]];
                            dataObj.averageSpeed = speedVal;
//                            self.speedField.text = [NSString stringWithFormat:@"%f",speedVal];
                            
                            if ([_dataStream count] == _arrayCapacity) {
                                [_dataStream removeObjectAtIndex:0];
                            }
                            [_dataStream addObject:dataObj];
                            
                            break;
                        }
                    }
                }
                
                // Draw graphs
                [self drawAccX:[NSArray arrayWithArray:_accX]];
                [self drawAccY:[NSArray arrayWithArray:_accY]];
                [self drawAccZ:[NSArray arrayWithArray:_accZ]];
                [self drawGyroX:[NSArray arrayWithArray:_gyroX]];
                [self drawGyroY:[NSArray arrayWithArray:_gyroY]];
                [self drawGyroZ:[NSArray arrayWithArray:_gyroZ]];
                [self drawSpeed:[NSArray arrayWithArray:_speed]];
            }
        }
    }
    
    // Update timestamp
    _lastTimestamp = [[NSDate date] dateByAddingTimeInterval:-kServeralIntervalTime];
}

- (void)drawAccX:(NSArray *)xAccVals {
    float lastXPos = 0.0;
    float lastXVal = 0.0;
    
    [_accXLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastXPos, zeroGraphAccYOffset+(lastXVal*10))];
    
    for (int i=0; i< [xAccVals count]; i++) {
        float xVal = [[xAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastXPos+5.0f, zeroGraphAccYOffset+(xVal*10))];
        lastXPos +=5;
        lastXVal = xVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _accXLayer = shapeLayer;
}

- (void)drawAccY:(NSArray *)yAccVals {
    float lastYPos = 0.0;
    float lastYVal = 0.0;
    
    [_accYLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastYPos, zeroGraphAccYOffset+(lastYVal*10))];
    
    for (int i=0; i< [yAccVals count]; i++) {
        float yVal = [[yAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastYPos+5.0f, zeroGraphAccYOffset+(yVal*10))];
        lastYPos +=5;
        lastYVal = yVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor greenColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _accYLayer = shapeLayer;
}

- (void)drawAccZ:(NSArray *)zAccVals {
    float lastZPos = 0.0;
    float lastZVal = 0.0;
    
    [_accZLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastZPos, zeroGraphAccYOffset+(lastZVal*10))];
    
    for (int i=0; i< [zAccVals count]; i++) {
        float zVal = [[zAccVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastZPos+5.0f, zeroGraphAccYOffset+(zVal*10))];
        lastZPos +=5;
        lastZVal = zVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _accZLayer = shapeLayer;
}

- (void)drawGyroX:(NSArray *)xGyroVals {
    float lastXPos = 0.0;
    float lastXVal = 0.0;
    
    [_gyroXLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastXPos, zeroGraphGyroYOffset+(lastXVal*10))];
    
    for (int i=0; i< [xGyroVals count]; i++) {
        float xVal = [[xGyroVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastXPos+5.0f, zeroGraphGyroYOffset+(xVal*10))];
        lastXPos +=5;
        lastXVal = xVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _gyroXLayer = shapeLayer;
}

- (void)drawGyroY:(NSArray *)yGyroVals {
    float lastYPos = 0.0;
    float lastYVal = 0.0;
    
    [_gyroYLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastYPos, zeroGraphGyroYOffset+(lastYVal*10))];
    
    for (int i=0; i< [yGyroVals count]; i++) {
        float yVal = [[yGyroVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastYPos+5.0f, zeroGraphGyroYOffset+(yVal*10))];
        lastYPos +=5;
        lastYVal = yVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor greenColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _gyroYLayer = shapeLayer;
}

- (void)drawGyroZ:(NSArray *)zGyroVals {
    float lastZPos = 0.0;
    float lastZVal = 0.0;
    
    [_gyroZLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastZPos, zeroGraphGyroYOffset+(lastZVal*10))];
    
    for (int i=0; i< [zGyroVals count]; i++) {
        float zVal = [[zGyroVals objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastZPos+5.0f, zeroGraphGyroYOffset+(zVal*10))];
        lastZPos +=5;
        lastZVal = zVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _gyroZLayer = shapeLayer;
}

- (void)drawSpeed:(NSArray *)speed {
    float lastSpeedPos = 0.0;
    float lastSpeedVal = 0.0;
    
    [_speedLayer removeFromSuperlayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(lastSpeedPos, zeroGraphSpeedYOffset+(lastSpeedVal))];
    
    for (int i=0; i< [speed count]; i++) {
        float speedVal = [[speed objectAtIndex:i] floatValue];
        [path addLineToPoint:CGPointMake(lastSpeedPos+5.0f, zeroGraphSpeedYOffset-(speedVal))];
        lastSpeedPos +=5;
        lastSpeedVal = speedVal;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.view.layer addSublayer:shapeLayer];
    _speedLayer = shapeLayer;
}

@end

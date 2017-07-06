//
//  BDMotionManager.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDMotionManager.h"
#import "AppDelegate.h"
#import "BDRouteData.h"
#import "BDDataPacket.h"
#import "BDLocData.h"
#import "BDDataSegment.h"
#import "BDServerDataManager.h"
#import <CoreMotion/CoreMotion.h>

static const NSTimeInterval updateInterval = 0.5; // 500 milliseconds

// Default MASTER trip recording values
static const NSInteger kArrayCapacity = 15;
static const float kAccValueDifference = 10.0;
static const float kGyroValueDifference = 10.0;

// Default data segmenting values
static const NSInteger kBaselineDataInterval = 30; // Gather data from this many seconds to calculate the baseline average
static const NSInteger kBaselineTolerance = 1; // The factor by which we compare the baseline values to find outliers and organize segments
static const NSInteger kVoilationTolerance = 100; // The factor by which we compare the incoming values to the peak values in a segment

@implementation BDMotionManager {
    // Master trip recording values
    NSMutableArray *_xAccVals;
    NSMutableArray *_yAccVals;
    NSMutableArray *_zAccVals;
    NSMutableArray *_xGyroVals;
    NSMutableArray *_yGyroVals;
    NSMutableArray *_zGyroVals;
    
    // normal trip processing values
    BOOL _started;
    NSString *_startDate;
    BDDataPacket *_currentPacket;
    CLLocation *_firstPacket;
    NSArray *_masterTripData;
    NSInteger _masterSegmentIndex;
    NSInteger _masterLocIndex;
    
    float _masterBaseline;
    NSMutableArray *_baselineToleranceArray;
    NSMutableArray *_violationToleranceArray;
    NSMutableArray *_sensorSegmentArrays; // Each item is an array of BDDataSegments representing the data for a specific sensor type, indexes matching BDMotionManagerSensorType
    NSMutableArray *_currentSegmentIndexes; // The current data segment for each specific sensor
    NSMutableArray *_currentItemIndexes; // The current item in each of the data segments defined by _currentSegmentIndexes.
}

static BDMotionManager *_sharedMotionManager;

+ (instancetype)sharedMotionManager {
    @synchronized([BDMotionManager class]) {
        if(!_sharedMotionManager) {
            NSLog(@"Creating Motion Manager");
            _sharedMotionManager  = [[BDMotionManager alloc] init];
        }
        return _sharedMotionManager;
    }
    return nil;
}

- (instancetype)init {
    if(self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // Most accurate location values
        self.locationManager.delegate = self;
        //  requestWhenInUseAuthorization is only available on iOS 8
        //  Make sure you also modify the application info.plist to include a NSLocationWhenInUseUsageDescription string
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            [self.locationManager requestWhenInUseAuthorization];
            
        }
        
        // Initialize global arrays
        _baselineToleranceArray = [NSMutableArray arrayWithCapacity:BDMotionManagerSensorTypeCount];
        _violationToleranceArray = [NSMutableArray arrayWithCapacity:BDMotionManagerSensorTypeCount];
        for (int i = 0; i < BDMotionManagerSensorTypeCount; i ++) {
            NSInteger baselineTolerance = kBaselineTolerance;
            NSInteger voilationTolerance = kVoilationTolerance;
            
            // Check to see if values have been stored already
            if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%d", BDBaselineToleranceKey, i]]) {
                float storedBaselineTolerance = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%d", BDBaselineToleranceKey, i]] floatValue];
                if (storedBaselineTolerance > 0) { // Ensure value is greater than 0
                    baselineTolerance = storedBaselineTolerance;
                }
            }
            if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%d", BDViolationToleranceKey, i]]) {
                float storedVoilationTolerance = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%d", BDViolationToleranceKey, i]] floatValue];
                if (storedVoilationTolerance > 0) { // Ensure value is greater than 0
                    voilationTolerance = storedVoilationTolerance;
                }
            }
            
            [_baselineToleranceArray addObject:[NSNumber numberWithInteger:baselineTolerance]];
            [_violationToleranceArray addObject:[NSNumber numberWithInteger:voilationTolerance]];
        }
    }
    return self;
}

- (NSNumber *_Nullable)getBaselineToleranceForSensorType:(BDMotionManagerSensorType)sensorType {
    return [_baselineToleranceArray objectAtIndex:sensorType];
}

- (NSNumber *_Nullable)getViolationToleranceForSensorType:(BDMotionManagerSensorType)sensorType {
    return [_violationToleranceArray objectAtIndex:sensorType];
}

- (void)setBaselineTolerance:(float)tolerance forSensorType:(BDMotionManagerSensorType)sensorType {
    NSNumber *newBaselineTolerance = [NSNumber numberWithFloat:tolerance];
    [_baselineToleranceArray replaceObjectAtIndex:sensorType withObject:newBaselineTolerance];
    
    // Store the value for future runs
    [[NSUserDefaults standardUserDefaults] setObject:newBaselineTolerance forKey:[NSString stringWithFormat:@"%@-%ld", BDBaselineToleranceKey, (long)sensorType]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setViolationTolerance:(float)tolerance forSensorType:(BDMotionManagerSensorType)sensorType {
    NSNumber *newViolationTolerance = [NSNumber numberWithFloat:tolerance];
    [_violationToleranceArray replaceObjectAtIndex:sensorType withObject:newViolationTolerance];
    
    // Store the value for future runs
    [[NSUserDefaults standardUserDefaults] setObject:newViolationTolerance forKey:[NSString stringWithFormat:@"%@-%ld", BDViolationToleranceKey, (long)sensorType]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)startMeasurements {
    if (!_started) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        _masterBaseline = 0;
        _masterSegmentIndex = 0;
        _masterLocIndex = 0;
        _startDate = [dateFormatter stringFromDate:[NSDate date]];
        _firstPacket = nil;
        
        // Setup arrays
        _currentPacket = [[BDDataPacket alloc] init];
        _xAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        _yAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        _zAccVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        _xGyroVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        _yGyroVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        _zGyroVals = [[NSMutableArray alloc] initWithCapacity:kArrayCapacity];
        
        _sensorSegmentArrays = [NSMutableArray arrayWithCapacity:BDMotionManagerSensorTypeCount];
        _currentSegmentIndexes = [NSMutableArray arrayWithCapacity:BDMotionManagerSensorTypeCount];
        _currentItemIndexes = [NSMutableArray arrayWithCapacity:BDMotionManagerSensorTypeCount];
        
        // TODO: Get driver ID from login system
        _currentPacket.driverID = [BDServerDataManager sharedDataManager].driverID;
        _currentPacket.routeID = [BDServerDataManager sharedDataManager].routeID;
        
        BDMotionManager * __weak weakSelf = self;
        // TODO: Store this in a database for actual release
        if ([[BDServerDataManager sharedDataManager] isMasterRecording] == NO) {
            _currentPacket.tripID = [[BDServerDataManager sharedDataManager] updateCurrentTripID];
            
            // Get master tripData
            [[BDServerDataManager sharedDataManager] getLocationDataForTripID:BDTripDataMASTERKey forRouteID:[BDServerDataManager sharedDataManager].routeID withCallback:^(NSArray * _Nullable locDataArray, NSError * _Nullable error) {
                if (error) {
                    [self stopMeasurements];
                    if (_delegate && [_delegate respondsToSelector:@selector(masterTripDataDownloadError:)]) {
                        [_delegate masterTripDataDownloadError:error];
                    }
                } else {
                    _masterTripData = locDataArray;
                    [weakSelf processMasterBDDataPackets];
                    [weakSelf startMonitoring];
                }
            }];
            
        } else {
            _currentPacket.tripID = BDTripDataMASTERKey;
            [self startMonitoring];
        }
        
        // Check whether the accelerometer is available
        //        if ([mManager isAccelerometerAvailable] == YES) {
        //            // Assign the update interval to the motion manager
        //            [mManager setAccelerometerUpdateInterval:updateInterval];
        //            [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        //                _currentPacket.accelerometerData = accelerometerData;
        //                [weakSelf sendLocData];
        //            }];
        //        }
        
        // Check whether the gyroscope is available
        //        if ([mManager isGyroAvailable] == YES) {
        //            // Assign the update interval to the motion manager
        //            [mManager setGyroUpdateInterval:updateInterval];
        //            [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        //                _currentPacket.gyroData = gyroData;
        //                [weakSelf sendLocData];
        //            }];
        //        }
        
        // Check whether the magnetometer is available
        //        if ([mManager isMagnetometerAvailable] == YES) {
        //            // Assign the update interval to the motion manager
        //            [mManager setMagnetometerUpdateInterval:updateInterval];
        //            [mManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
        //                _currentPacket.magData = magnetometerData;
        //                [weakSelf sendLocData];
        //            }];
        //        }
        
        //        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)startMonitoring {
    BDMotionManager * __weak weakSelf = self;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    // Start location manger
    [self.locationManager startUpdatingLocation];
    
    // Create a CMMotionManager
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedCMMotionManager];
    
    // Check whether the deviceMotion handler is available
    if ([mManager isDeviceMotionAvailable] == YES) {
        // Assign the update interval to the motion manager
        [mManager setDeviceMotionUpdateInterval:updateInterval];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            // Set values and handle accelerometer and gyroscope data
            _currentPacket.timestamp = [dateFormatter stringFromDate:[NSDate date]];
            _currentPacket.violation = BDMotionManagerViolationTypeNone;
            _currentPacket.accelerometerData = motion.userAcceleration;
            _currentPacket.rotationData = motion.rotationRate;
            
            // Now check for violations
            BDMotionManagerViolationType violation = BDMotionManagerViolationTypeNone;
            if ([[BDServerDataManager sharedDataManager] isMasterRecording] == NO) {
                violation = [weakSelf compareDataToMasterData:motion];
            } else {
                // TODO: Make this more robust
                violation = [weakSelf checkForTurnSpikeWithData:motion.rotationRate];
                if (violation == BDMotionManagerViolationTypeNone) {
                    violation = [weakSelf checkForAccSpikeWithData:motion.userAcceleration];
                }
                
                // Update the data smoothing arrays
                [weakSelf updateDataArrays:motion];
            }
            _currentPacket.violation = violation;
            
            // Notify the delegate if there is a violation
            if (violation > BDMotionManagerViolationTypeNone) {
                [weakSelf notifyDelegateOfUnsafeDriving:violation];
            }
            
            // Process packet and send to server
            [[BDServerDataManager sharedDataManager] sendLocData:_currentPacket];
        }];
    }
    _started = YES;
}

- (void)stopMeasurements {
    if (_started) {
        
        // If we are tracking it, stop tracking it
        if (self.locationManager) {
            [self.locationManager stopUpdatingLocation];
        }
        CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedCMMotionManager];
        if ([mManager isDeviceMotionActive] == YES) {
            [mManager stopDeviceMotionUpdates];
        }
        if ([mManager isAccelerometerActive] == YES) {
            [mManager stopAccelerometerUpdates];
        }
        if ([mManager isGyroActive] == YES) {
            [mManager stopGyroUpdates];
        }
        if ([mManager isMagnetometerActive] == YES) {
            [mManager stopMagnetometerUpdates];
        }
        
        // Send the trip data for the driver - but only if this is not a master recording
        if ([[BDServerDataManager sharedDataManager] isMasterRecording] == NO) {
            BDTripData *tripDataObj = [[BDTripData alloc] init];
            tripDataObj.routeID = _currentPacket.routeID;
            tripDataObj.tripID = _currentPacket.tripID;
            tripDataObj.driverID = _currentPacket.driverID;
            tripDataObj.score = @"10";
            tripDataObj.load = @"1000";
            [[BDServerDataManager sharedDataManager] sendTripData:tripDataObj];
        } else {
            // Create a new route for the MASTER data
            BDRouteData *routeDataObj = [[BDRouteData alloc] init];
            routeDataObj.routeID = [BDServerDataManager sharedDataManager].routeID;
            routeDataObj.routeName = [BDServerDataManager sharedDataManager].routeName;
            routeDataObj.routeStartLocation = _firstPacket;
            routeDataObj.routeEndLocation = _currentPacket.location;
            [[BDServerDataManager sharedDataManager] sendRouteData:routeDataObj];
        }
        
        _started = NO;
        _firstPacket = nil;
    }
}

#pragma mark - Data Processing

- (void)processMasterBDDataPackets {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    BDLocData *initialObject = [_masterTripData firstObject];
    NSDate *masterTripStartDate = [dateFormatter dateFromString:initialObject.timestamp];
    
    // Create segmented arrays for each sensor type
    for (NSInteger sensorType = 0; sensorType < BDMotionManagerSensorTypeCount; sensorType++) {
        NSLog(@"Creating segments for sensor %@", SensorTypeStringFromBDMotionManagerSensorType(sensorType));
        NSMutableArray *sensorArray = [NSMutableArray array];
        float sensorBaseline = 0;
        float sensorValueSum = 0;
        float sensorDataCount = 0;
        NSInteger dataIndex;
        NSMutableArray *baselineSegmentArray = [NSMutableArray array];
        NSInteger baselineTolerance = [[_baselineToleranceArray objectAtIndex:sensorType] integerValue];
        
        // First, calculate the baseline using the first kBaselineDataInterval seconds of data
        for (dataIndex = 0; dataIndex < _masterTripData.count; dataIndex++) {
            BDLocData *dataObj = [_masterTripData objectAtIndex:dataIndex];
            
            // Check the timestamp
            NSDate *dataDate = [dateFormatter dateFromString:dataObj.timestamp];
            if ([dataDate timeIntervalSinceDate:masterTripStartDate] > kBaselineDataInterval) {
                // If we are beyond the time interval for the baseline, break the loop
                break;
            } else { // Otherwise add the absolute value of the sensor data for averaging
                sensorValueSum += ABS([dataObj valueForSensorType:sensorType]);
                sensorDataCount ++;
                [baselineSegmentArray addObject:dataObj];
            }
        }
        
        // Calculate the average value for the baseline and multiply by the tolerance to find the upper and lower limit baseline values
        sensorBaseline = (sensorValueSum / sensorDataCount) * baselineTolerance;
        BDDataSegment *baselineDataSegment = [BDDataSegment initWithSegmentData:baselineSegmentArray andSensorType:sensorType];
        [sensorArray addObject:baselineDataSegment];
        
        
        // Next, loop through the rest of the data to find segments based on sensorBaseline
        for (NSInteger j = dataIndex; j < _masterTripData.count; j++) {
        // TODO: There is probably a nicer, recursive way to do this
            
            BDLocData *dataObj = [_masterTripData objectAtIndex:j];
            float sensorData = [dataObj valueForSensorType:sensorType];
            
            // If the value is positive and beyond the upper limit of the baseline
            if (sensorData > 0 && sensorData > sensorBaseline) {
                NSMutableArray *upperSegmentArray = [NSMutableArray array];
                
                // Now loop through and add all objects that match the profile
                for (NSInteger k = j; k < _masterTripData.count; k++) {
                    BDLocData *upperDataObj = [_masterTripData objectAtIndex:k];
                    
                    // Ensure the new value is also within the limits of the segment
                    float upperSensorData = [dataObj valueForSensorType:sensorType];
                    if (upperSensorData > 0 && upperSensorData > sensorBaseline) {
                        [upperSegmentArray addObject:upperDataObj];
                    } else { // If we are outside of the current segment
                        j = k-1; // Move to the parent loop using the non-matching object
                        break;
                    }
                }
                
                // Calculate the peak value of the segment and the segment type and store the new segment in the sensorArray
                BDDataSegment *upperDataSegment = [BDDataSegment initWithSegmentData:upperSegmentArray andSensorType:sensorType];
                [sensorArray addObject:upperDataSegment];
                
            } else if (sensorData < 0 && sensorData < (-1*sensorBaseline)) { // else if the value is negative beyond the lower limit of the baseline
                NSMutableArray *lowerSegmentArray = [NSMutableArray array];
                
                // Now loop through and add all objects that match the profile
                for (NSInteger k = j; k < _masterTripData.count; k++) {
                    BDLocData *lowerDataObj = [_masterTripData objectAtIndex:k];
                    float lowerSensorData = [lowerDataObj valueForSensorType:sensorType];
                    
                    // Ensure the new value is also within the limits of the segment
                    if (lowerSensorData < 0 && lowerSensorData < (-1*sensorBaseline)) {
                        [lowerSegmentArray addObject:lowerDataObj];
                    } else { // If we are outside of the current segment
                        j = k-1; // Move to the parent loop using the non-matching object
                        break;
                    }
                }
                
                // Calculate the peak value of the segment and the segment type and store the new segment in the sensorArray
                BDDataSegment *lowerDataSegment = [BDDataSegment initWithSegmentData:lowerSegmentArray andSensorType:sensorType];
                [sensorArray addObject:lowerDataSegment];
                
            } else { // For all other "baseline compliant" data
                NSMutableArray *segmentArray = [NSMutableArray array];
                
                // Now loop through and add all objects that match the profile
                for (NSInteger k = j; k < _masterTripData.count; k++) {
                    BDLocData *dataObj = [_masterTripData objectAtIndex:k];
                    float sensorData = [dataObj valueForSensorType:sensorType];
                    
                    // If we are outside of the current segment, do not add
                    if ((sensorData > 0 && sensorData > sensorBaseline) ||
                        (sensorData < 0 && sensorData < (-1*sensorBaseline))) {
                        j = k-1; // Move to the parent loop using the non-matching object
                        break;
                    } else { // Otherwise
                        [segmentArray addObject:dataObj];
                    }
                }
                
                // Calculate the peak value of the segment and the segment type and store the new segment in the sensorArray
                BDDataSegment *dataSegment = [BDDataSegment initWithSegmentData:segmentArray andSensorType:sensorType];
                [sensorArray addObject:dataSegment];
            }
        }
        
        // Now add the array of segments for a speficic sensor to the maser array
        [_sensorSegmentArrays addObject:sensorArray];
        NSLog(@"Created %ld segments out of %ld items", (long)sensorArray.count, (long)_masterTripData.count);
    }
}

- (BDMotionManagerViolationType)compareDataToMasterData:(CMDeviceMotion * _Nonnull )motion {
    
    // Check for violations on each sensor type
    for (NSInteger sensorType = 0; sensorType < BDMotionManagerSensorTypeCount; sensorType++) {
        
        // Get the segment array and violation tolerance for this sensor type
        NSArray *segmentArray = [_sensorSegmentArrays objectAtIndex:sensorType];
        NSInteger violationTolerance = [[_violationToleranceArray objectAtIndex:sensorType] integerValue];
        
        // If we have not compared this data before
        if ([_currentSegmentIndexes count] <= sensorType) {
            // Assume the closest item is the first segment
            [_currentSegmentIndexes addObject:[NSNumber numberWithInteger:0]];
        }

        // Get the current segment index
        NSInteger currentSegmentIndex = [[_currentSegmentIndexes objectAtIndex:sensorType] integerValue];
        CLLocationDistance lastClosestDistanceToCurrent = DBL_MAX;
        
        // Loop through each segment looking for closest item based on GPS, starting from current segment
        for (NSInteger segmentIndex = currentSegmentIndex; segmentIndex < segmentArray.count; segmentIndex ++) {
            BDDataSegment *currentSegment = [segmentArray objectAtIndex:segmentIndex];
            CLLocationDistance closestDistanceToCurrent = DBL_MAX;
            
            // Find the closest distance to the new data using the current segment
            for (BDLocData *locObj in currentSegment.segmentData) {
                // Get the distance between the points
                CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:locObj.latitude longitude:locObj.longitude];
                CLLocationDistance distance = [_currentPacket.location distanceFromLocation:currentLocation];
                    
                // The first object will always be selected
                if (distance <= closestDistanceToCurrent) {
                    closestDistanceToCurrent = distance;
                }
            }
            
            // If this segment is closer to the previous segment
            if (closestDistanceToCurrent <= lastClosestDistanceToCurrent) {
                lastClosestDistanceToCurrent = closestDistanceToCurrent;
                // Store current segment index, as this is the one we want
                [_currentSegmentIndexes replaceObjectAtIndex:sensorType withObject:[NSNumber numberWithInteger:segmentIndex]];
            } else {
                // If the current segment is further away than the last one, break because that one was the one we wanted
                break;
            }
        }

        // Now compare the values of current object and the segment
        NSInteger newSegmentIndex = [[_currentSegmentIndexes objectAtIndex:sensorType] integerValue];
        BDDataSegment *closestSegment = [segmentArray objectAtIndex:newSegmentIndex];
        if (ABS([_currentPacket valueForSensorType:sensorType]) > (ABS(closestSegment.peakValue)*violationTolerance)) {
            // Return the violation type depending on the motion type
            BDMotionManagerViolationType voilationType =  BDMotionManagerViolationTypeFromBDMotionManagerSensorType(sensorType);
            // Special case for stopping/accelerating
            if (voilationType == BDMotionManagerViolationTypeStopping && [_currentPacket valueForSensorType:sensorType] > 0) {
                voilationType = BDMotionManagerViolationTypeAcceleration;
            }
            return voilationType;
        }
    }
    
    // If no violations are found return as such
    return BDMotionManagerViolationTypeNone;
}

/* 
 // OLD LOGIC
- (BDMotionManagerViolationType)compareDataToMasterData:(CMDeviceMotion * _Nonnull )motion {
    BDMotionManagerViolationType voilation = BDMotionManagerViolationTypeNone;
    
    BDLocData *masterLocData = nil;
    NSInteger lastFoundIndex = -1;
    NSInteger closestInterval = DBL_MAX;
    CLLocationDistance closestDistance = DBL_MAX;
    NSMutableArray *locObjsMatchingLoc = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *currentStartDate = [dateFormatter dateFromString:_startDate];
    NSDate *currentDate = [dateFormatter dateFromString:_currentPacket.timestamp];
    NSTimeInterval currentInterval = ABS([currentDate timeIntervalSinceDate:currentStartDate]);
    
    // Find the locations in the master list that are closest to the current BDDataPacket
    for (NSInteger i = _masterLocIndex; i < _masterTripData.count; i++) {
        BDLocData *locObj = [_masterTripData objectAtIndex:i];
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:locObj.latitude longitude:locObj.longitude];
        CLLocationDistance distance = [_currentPacket.location distanceFromLocation:currentLocation];
        
        // The first object will always be selected
        if (distance < closestDistance) {
            lastFoundIndex = i;
            closestDistance = distance;
            locObjsMatchingLoc = [NSMutableArray array];
            [locObjsMatchingLoc addObject:locObj];
        } else if (distance == closestDistance) {
            // If it is within the same distance, we add it to the array
            lastFoundIndex = i;
            closestDistance = distance;
            [locObjsMatchingLoc addObject:locObj];
        }
    }
    
    // If we have at least one object, compare to the current one
    if (locObjsMatchingLoc && [locObjsMatchingLoc count] > 0) {
        // Increase the index so that we always start from the last used position only
        _masterLocIndex = lastFoundIndex;
        
        // If there was only one match, we must assume that was
        if ([locObjsMatchingLoc count] == 1) {
            NSLog(@"Found a single matching location object");
            masterLocData = [locObjsMatchingLoc firstObject];
            
        } else {// If there are more than one object, perform the same check using the start time vs current time values
            NSLog(@"Found more than one location object, searching for closest match");
            BDLocData *masterStartObj = [_masterTripData objectAtIndex:0];
            NSDate *masterStartDate = [dateFormatter dateFromString:masterStartObj.timestamp];
            // Loop through each of the found objects and find the closest matching date
            // TODO: This will need to be refactored to account for speed, or removed entirely
            for (int j=0; j<locObjsMatchingLoc.count; j++) {
                BDLocData *foundLocObj = [locObjsMatchingLoc objectAtIndex:j];
                NSDate *locDate = [dateFormatter dateFromString:foundLocObj.timestamp];
                NSTimeInterval interval = ABS([locDate timeIntervalSinceDate:masterStartDate]);
                NSInteger intervalDiff = ABS(currentInterval - interval);
                
                // The first object will always be selected
                if (intervalDiff < closestInterval) {
                    // If the difference in time is less than the previous, we reset the array and add the object to it
                    closestInterval = intervalDiff;
                    masterLocData = foundLocObj;
                }
            }
        }
        
        // Now compare the values of the two objects and
        return [self compareCurrentDataToMasterData:masterLocData];
        
    } else {
        NSLog(@"No matches found for content");
        return voilation;
    }
    return voilation;
}

- (BDMotionManagerViolationType)compareCurrentDataToMasterData:(BDLocData *)masterLocData {
    // Compare accX
    if (ABS(masterLocData.accX - _currentPacket.accelerometerData.x) > ABS(masterLocData.accX * kAccValueDifference)) {
        NSLog(@"Spike detected on accelleration X-axis.");
        return BDMotionManagerViolationTypeTurning;
    }
    
    // Compare accY
    if (ABS(masterLocData.accY - _currentPacket.accelerometerData.y) > ABS(masterLocData.accY * kAccValueDifference)) {
        NSLog(@"Spike detected on accelleration Y-axis.");
        return BDMotionManagerViolationTypeStopping;
    }
    
    // Compare accZ
    if (ABS(masterLocData.accZ - _currentPacket.accelerometerData.z) > ABS(masterLocData.accZ * kAccValueDifference)) {
        NSLog(@"Spike detected on accelleration Z-axis.");
        return BDMotionManagerViolationTypeSpeed;
    }
    
    // Compare gyroX
    if (ABS(masterLocData.gyroX - _currentPacket.rotationData.x) > ABS(masterLocData.gyroX * kGyroValueDifference)) {
        NSLog(@"Spike detected on rotation on X-axis.");
        return BDMotionManagerViolationTypeSpeed;
    }
    
    // Compare gyroY
    if (ABS(masterLocData.gyroY - _currentPacket.rotationData.y) > ABS(masterLocData.gyroY * kGyroValueDifference)) {
        NSLog(@"Spike detected on rotation on Y-axis.");
        return BDMotionManagerViolationTypeTurning;
    }
    
    // Compare gyroZ
    if (ABS(masterLocData.gyroZ - _currentPacket.rotationData.z) > ABS(masterLocData.gyroZ * kGyroValueDifference)) {
        NSLog(@"Spike detected on rotation on Z-axis.");
        return BDMotionManagerViolationTypeTurning;
    }
    
    return BDMotionManagerViolationTypeNone;
}
 */

- (BDMotionManagerViolationType)checkForAccSpikeWithData:(CMAcceleration)accelerometerData {
    float xSum = 0.0, ySum = 0.0, zSum = 0.0;
    float xAverage, yAverage, zAverage;
    
    if (_xAccVals.count == kArrayCapacity) {
        for (NSNumber *xVal in _xAccVals) {
            xSum += ABS([xVal floatValue]);
        }
        xAverage = xSum / kArrayCapacity;
        NSInteger baselineToleranceX = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeAccX] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(xAverage*baselineToleranceX) < ABS(accelerometerData.x)) {
            NSLog(@"Spike detected on accelleration X-axis.");
            return BDMotionManagerViolationTypeTurning;;
        }
    }
    
    if (_yAccVals.count == kArrayCapacity) {
        for (NSNumber *yVal in _yAccVals) {
            ySum += ABS([yVal floatValue]);
        }
        yAverage = ySum / kArrayCapacity;
        NSInteger baselineToleranceY = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeAccY] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(yAverage*baselineToleranceY) < ABS(accelerometerData.y)) {
            NSLog(@"Spike detected on accelleration Y-axis.");
            return BDMotionManagerViolationTypeSpeed;
        }
    }
    
    if (_zAccVals.count == kArrayCapacity) {
        for (NSNumber *zVal in _zAccVals) {
            zSum += ABS([zVal floatValue]);
        }
        zAverage = zSum / kArrayCapacity;
        NSInteger baselineToleranceZ = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeAccZ] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(zAverage*baselineToleranceZ) < ABS(accelerometerData.z)) {
            NSLog(@"Spike detected on accelleration Z-axis.");
            if (accelerometerData.z > 0) {
                return BDMotionManagerViolationTypeAcceleration;
            } else {
                return BDMotionManagerViolationTypeStopping;
            }
        }
    }
    
    return BDMotionManagerViolationTypeNone;
}

- (BDMotionManagerViolationType)checkForTurnSpikeWithData:(CMRotationRate)rotationRate {
    float xSum = 0.0, ySum = 0.0, zSum = 0.0;
    float xAverage, yAverage, zAverage;
    
    if (_xGyroVals.count == kArrayCapacity) {
        for (NSNumber *xVal in _xGyroVals) {
            xSum += ABS([xVal floatValue]);
        }
        xAverage = xSum / kArrayCapacity;
        NSInteger baselineToleranceX = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeGyroX] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(xAverage*baselineToleranceX) < ABS(rotationRate.x)) {
            NSLog(@"Spike detected on rotation on X-axis.");
            return BDMotionManagerViolationTypeSpeed;
        }
    }
    
    if (_yGyroVals.count == kArrayCapacity) {
        for (NSNumber *yVal in _yGyroVals) {
            ySum += ABS([yVal floatValue]);
        }
        yAverage = ySum / kArrayCapacity;
        NSInteger baselineToleranceY = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeGyroY] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(yAverage*baselineToleranceY) < ABS(rotationRate.y)) {
            NSLog(@"Spike detected on rotation on Y-axis.");
            return BDMotionManagerViolationTypeTurning;
        }
    }
    
    if (_zGyroVals.count == kArrayCapacity) {
        for (NSNumber *zVal in _zGyroVals) {
            zSum += ABS([zVal floatValue]);
        }
        zAverage = zSum / kArrayCapacity;
        NSInteger baselineToleranceZ = [[_baselineToleranceArray objectAtIndex:BDMotionManagerSensorTypeGyroZ] integerValue];
        
        // If the new value is 10x greater than the average from the previous data, show a spike.
        if (ABS(zAverage*baselineToleranceZ) < ABS(rotationRate.z)) {
            NSLog(@"Spike detected on rotation on Z-axis.");
            return BDMotionManagerViolationTypeTurning;
        }
    }
    
    return BDMotionManagerViolationTypeNone;
}

- (void)updateDataArrays:(CMDeviceMotion * _Nonnull )motion {
    // If the rolling buffer is full, remove the last object and add the new one at the beginning
    
    if ([_xAccVals count] == kArrayCapacity) {
        [_xAccVals removeLastObject];
    }
    [_xAccVals insertObject:[NSNumber numberWithFloat:motion.userAcceleration.x] atIndex:0];
    
    if ([_yAccVals count] == kArrayCapacity) {
        [_yAccVals removeLastObject];
    }
    [_yAccVals insertObject:[NSNumber numberWithFloat:motion.userAcceleration.y] atIndex:0];
    
    if ([_zAccVals count] == kArrayCapacity) {
        [_zAccVals removeLastObject];
    }
    [_zAccVals insertObject:[NSNumber numberWithFloat:motion.userAcceleration.z] atIndex:0];
    
    if ([_xGyroVals count] == kArrayCapacity) {
        [_xGyroVals removeLastObject];
    }
    [_xGyroVals insertObject:[NSNumber numberWithFloat:motion.rotationRate.x] atIndex:0];
    
    if ([_yGyroVals count] == kArrayCapacity) {
        [_yGyroVals removeLastObject];
    }
    [_yGyroVals insertObject:[NSNumber numberWithFloat:motion.rotationRate.y] atIndex:0];
    
    if ([_zGyroVals count] == kArrayCapacity) {
        [_zGyroVals removeLastObject];
    }
    [_zGyroVals insertObject:[NSNumber numberWithFloat:motion.rotationRate.z] atIndex:0];
}


#pragma mark - Delegates

- (void)notifyDelegateOfUnsafeDriving:(BDMotionManagerViolationType)violationType {
    if (_delegate && [_delegate respondsToSelector:@selector(detetectedMotionViolation:)]) {
        [_delegate detetectedMotionViolation:violationType];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    
    // If the first packet has not been stored for the starting location, set it
    if (_firstPacket == nil) {
        _firstPacket = location;
    }
    
    // Store the last known location  for the current data packet to be sent
    _currentPacket.location = location;
}

@end


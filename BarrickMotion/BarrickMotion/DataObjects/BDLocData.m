//
//  BDLocData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-06-09.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDLocData.h"

@implementation BDLocData

- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        _timestamp = [dict objectForKey:BDLocDataTimestampKey];
        _driverID = [dict objectForKey:BDLocDataDriverIDKey];
        _routeID = [dict objectForKey:BDLocDataRouteIDKey];
        _tripID = [dict objectForKey:BDLocDataTripIDKey];
        _violation = [[dict objectForKey:BDLocDataViolationKey] integerValue];
        _longitude = [[dict objectForKey:BDLocDataLongKey] floatValue];
        _latitude = [[dict objectForKey:BDLocDataLatKey] floatValue];
        _accX = [[dict objectForKey:BDLocDataAccXKey] floatValue];
        _accY = [[dict objectForKey:BDLocDataAccYKey] floatValue];
        _accZ = [[dict objectForKey:BDLocDataAccZKey] floatValue];
        _gyroX = [[dict objectForKey:BDLocDataGyroXKey] floatValue];
        _gyroY = [[dict objectForKey:BDLocDataGyroYKey] floatValue];
        _gyroZ = [[dict objectForKey:BDLocDataGyroZKey] floatValue];
        
        return self;
    }
    return nil;
}

- (float)valueForSensorType:(BDMotionManagerSensorType)sensorType {
    float currVal = 0;
    switch (sensorType) {
        case BDMotionManagerSensorTypeGyroX:
            currVal = _gyroX;
            break;
        case BDMotionManagerSensorTypeGyroY:
            currVal = _gyroY;
            break;
        case BDMotionManagerSensorTypeGyroZ:
            currVal = _gyroZ;
            break;
        case BDMotionManagerSensorTypeAccX:
            currVal = _accX;
            break;
        case BDMotionManagerSensorTypeAccY:
            currVal = _accY;
            break;
        case BDMotionManagerSensorTypeAccZ:
            currVal = _accZ;
            break;
        default:
            break;
    }
    return currVal;
}

@end

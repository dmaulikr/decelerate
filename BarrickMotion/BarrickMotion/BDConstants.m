//
//  BDConstants.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-06-09.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDConstants.h"

NSString *const BDLocDataTimestampKey       = @"timestamp";
NSString *const BDLocDataDriverIDKey        = @"driverID";
NSString *const BDLocDataRouteIDKey         = @"routeID";
NSString *const BDLocDataTripIDKey          = @"tripID";
NSString *const BDLocDataViolationKey       = @"violation";
NSString *const BDLocDataLongKey            = @"longitude";
NSString *const BDLocDataLatKey             = @"latitude";
NSString *const BDLocDataAccXKey            = @"accX";
NSString *const BDLocDataAccYKey            = @"accY";
NSString *const BDLocDataAccZKey            = @"accZ";
NSString *const BDLocDataGyroXKey           = @"gyroX";
NSString *const BDLocDataGyroYKey           = @"gyroY";
NSString *const BDLocDataGyroZKey           = @"gyroZ";

NSString *const BDTripDataMASTERKey         = @"MASTER";
NSString *const BDTripDataTimestampKey      = @"timestamp";
NSString *const BDTripDataScoreKey          = @"score";
NSString *const BDTripDataLoadKey           = @"loadTons";

NSString *const BDRouteDataNameKey          = @"routeName";
NSString *const BDRouteDataStartLocLonKey   = @"startLocLon";
NSString *const BDRouteDataStartLocLatKey   = @"startLocLat";
NSString *const BDRouteDataEndLocLonKey     = @"endLocLon";
NSString *const BDRouteDataEndLocLatKey     = @"endLocLat";

NSString *const BDTRankingDataDriverIDKey = @"driverID";
NSString *const BDTRankingDataRankKey     = @"rank";
NSString *const BDTRankingDataNameKey     = @"name";
NSString *const BDTRankingDataStarsKey    = @"stars";
NSString *const BDTRankingDataScoreKey    = @"score";

NSString *const BDBaselineToleranceKey      = @"baselineTolerance";
NSString *const BDViolationToleranceKey     = @"voilationTolerance";

@implementation BDConstants
@end

NSString * _Nonnull ViolationStringFromBDMotionManagerViolationType(BDMotionManagerViolationType violationType) {
    switch (violationType) {
        case BDMotionManagerViolationTypeSpeed:
            return @"SLOW DOWN";
            break;
        case BDMotionManagerViolationTypeStopping:
            return @"STOP EARLIER";
            break;
        case BDMotionManagerViolationTypeAcceleration:
            return @"LESS GASS";
            break;
        case BDMotionManagerViolationTypeTurning:
            return @"TURN SLOWER";
            break;
        default:
            return @"GOOD SPEED";
            break;
    }
}

NSString * _Nonnull SensorTypeStringFromBDMotionManagerSensorType(BDMotionManagerSensorType sensorType) {
    switch (sensorType) {
        case BDMotionManagerSensorTypeGyroX:
            return @"gyroX";
            break;
        case BDMotionManagerSensorTypeGyroY:
            return @"gyroY";
            break;
        case BDMotionManagerSensorTypeGyroZ:
            return @"gyroZ";
            break;
        case BDMotionManagerSensorTypeAccX:
            return @"accX";
            break;
        case BDMotionManagerSensorTypeAccY:
            return @"accY";
            break;
        case BDMotionManagerSensorTypeAccZ:
            return @"accZ";
            break;
        default:
            return nil;
            break;
    }
}

BDMotionManagerViolationType BDMotionManagerViolationTypeFromBDMotionManagerSensorType(BDMotionManagerSensorType sensorType) {
    switch (sensorType) {
        case BDMotionManagerSensorTypeGyroX:
            return BDMotionManagerViolationTypeSpeed;
            break;
        case BDMotionManagerSensorTypeGyroY:
            return BDMotionManagerViolationTypeTurning;
            break;
        case BDMotionManagerSensorTypeGyroZ:
            return BDMotionManagerViolationTypeTurning;
            break;
        case BDMotionManagerSensorTypeAccX:
            return BDMotionManagerViolationTypeTurning;
            break;
        case BDMotionManagerSensorTypeAccY:
            return BDMotionManagerViolationTypeSpeed;
            break;
        case BDMotionManagerSensorTypeAccZ:
            return BDMotionManagerViolationTypeStopping;
            break;
        default:
            return BDMotionManagerViolationTypeNone;
            break;
    }
}

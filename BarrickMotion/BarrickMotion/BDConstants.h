//
//  BDConstants.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-06-09.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString * _Nonnull const BDLocDataTimestampKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataDriverIDKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataRouteIDKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataTripIDKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataViolationKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataLongKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataLatKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataAccXKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataAccYKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataAccZKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataGyroXKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataGyroYKey;
OBJC_EXTERN NSString * _Nonnull const BDLocDataGyroZKey;

OBJC_EXTERN NSString * _Nonnull const BDTripDataMASTERKey;
OBJC_EXTERN NSString * _Nonnull const BDTripDataTimestampKey;
OBJC_EXTERN NSString * _Nonnull const BDTripDataScoreKey;
OBJC_EXTERN NSString * _Nonnull const BDTripDataLoadKey;

OBJC_EXTERN NSString *_Nonnull const BDRouteDataNameKey;
OBJC_EXTERN NSString *_Nonnull const BDRouteDataStartLocLonKey;
OBJC_EXTERN NSString *_Nonnull const BDRouteDataStartLocLatKey;
OBJC_EXTERN NSString *_Nonnull const BDRouteDataEndLocLonKey;
OBJC_EXTERN NSString *_Nonnull const BDRouteDataEndLocLatKey;

OBJC_EXTERN NSString *_Nonnull const BDTRankingDataDriverIDKey;
OBJC_EXTERN NSString *_Nonnull const BDTRankingDataRankKey;
OBJC_EXTERN NSString *_Nonnull const BDTRankingDataNameKey;
OBJC_EXTERN NSString *_Nonnull const BDTRankingDataStarsKey;
OBJC_EXTERN NSString *_Nonnull const BDTRankingDataScoreKey;

OBJC_EXTERN NSString *_Nonnull const BDBaselineToleranceKey;
OBJC_EXTERN NSString *_Nonnull const BDViolationToleranceKey;

/**
 * Types of motion events / segments
 */
typedef NS_ENUM(NSInteger, BDMotionManagerMotionType) {
    BDMotionManagerMotionTypeBaseline = 0,
    BDMotionManagerMotionTypeTurnLeft,
    BDMotionManagerMotionTypeTurnRight,
    BDMotionManagerMotionTypeAcceleration,
    BDMotionManagerMotionTypeStopping,
    BDMotionManagerMotionTypeBump,
    BDMotionManagerMotionTypeCount
};

/**
 * Types of motion events / segments
 */
typedef NS_ENUM(NSInteger, BDMotionManagerSensorType) {
    BDMotionManagerSensorTypeGyroX = 0,
    BDMotionManagerSensorTypeGyroY,
    BDMotionManagerSensorTypeGyroZ,
    BDMotionManagerSensorTypeAccX,
    BDMotionManagerSensorTypeAccY,
    BDMotionManagerSensorTypeAccZ,
    BDMotionManagerSensorTypeCount
};
OBJC_EXPORT NSString * _Nonnull SensorTypeStringFromBDMotionManagerSensorType(BDMotionManagerSensorType sensorType);

/**
 * Types of violations
 */
typedef NS_ENUM(NSInteger, BDMotionManagerViolationType) {
    BDMotionManagerViolationTypeNone = 0,
    BDMotionManagerViolationTypeSpeed,
    BDMotionManagerViolationTypeStopping,
    BDMotionManagerViolationTypeAcceleration,
    BDMotionManagerViolationTypeTurning,
    BDMotionManagerViolationTypeCount
};
OBJC_EXPORT NSString * _Nonnull ViolationStringFromBDMotionManagerViolationType(BDMotionManagerViolationType violationType);
OBJC_EXPORT BDMotionManagerViolationType BDMotionManagerViolationTypeFromBDMotionManagerSensorType(BDMotionManagerSensorType sensorType);

/**
 * Types of annotations to be displayed
 */
typedef NS_ENUM(NSInteger, BDAnnotationType) {
    BDAnnotationTypeNormalDriving = 0,
    BDAnnotationTypeUnsafeDriving,
    BDAnnotationTypeCount
};


@interface BDConstants : NSObject
@end

//
//  BDMotionManager.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BDConstants.h"

@protocol BDMotionManagerDelegate;

/**
 * Manages capturing, processing, and comparing of motion information
 */
@interface BDMotionManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager * _Nullable locationManager;
@property (nonatomic, strong) id<BDMotionManagerDelegate> _Nullable delegate;

/**
 * Returns the shared manager instance
 */
+ (instancetype _Nullable )sharedMotionManager;

/** 
 * Starts a new recording session and records sensor and location data to send to the server
 */
- (void)startMeasurements;

/**
 * Ends the current recording session
 */
- (void)stopMeasurements;

/**
 * Returns the stored tolerance value for the given sensor when determining baselines
 * @param sensorType The sensor for which to return the defined tolerance
 * @return An NSNumber representing the tolerance value
 */
- (NSNumber *_Nullable)getBaselineToleranceForSensorType:(BDMotionManagerSensorType)sensorType;

/**
 * Returns the stored tolerance value for the given sensor when determining violations based on the baseline
 * @param sensorType The sensor for which to return the defined tolerance
 * @return An NSNumber representing the tolerance value
 */
- (NSNumber *_Nullable)getViolationToleranceForSensorType:(BDMotionManagerSensorType)sensorType;

/**
 * Stores the updated value for the given sensor when determining baselines
 * @param tolerance  A float value representing the tolerance value
 * @param sensorType The sensor for which to return the defined tolerance
 */
- (void)setBaselineTolerance:(float)tolerance forSensorType:(BDMotionManagerSensorType)sensorType;

/**
 * Stores the updated value for the given sensor when determining violations based on the baseline
 * @param tolerance  A float value representing the tolerance value
 * @param sensorType The sensor for which to return the defined tolerance
 */
- (void)setViolationTolerance:(float)tolerance forSensorType:(BDMotionManagerSensorType)sensorType;

@end

/** 
 * Delegate model for classes that whish to be notified of updates from the BDMotionManager
 */
@protocol BDMotionManagerDelegate <NSObject>

/**
 * Notifies the delegate that the motion manager has detected a motion violation
 * @param violationType An enum representing the type of motion violation that has been encountered
 */
- (void)detetectedMotionViolation:(BDMotionManagerViolationType)violationType;

/**
 * Notifies the delegate that the motion manager has failed to download the MASTER trip data to compare to the current trip
 * @param error An NSError object representing the error encountered during the attempted download
 */
- (void)masterTripDataDownloadError:(NSError *_Nullable)error;

@end

//
//  BDDataSegment.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-06-29.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDConstants.h"

/**
 * A segment of BDLocData objects grouped together to represent a specific motion (turn, breaking, etc) 
 */
@interface BDDataSegment : NSObject

@property(nonatomic, strong, readonly, nonnull) NSArray *segmentData; // Array of BDLocData objects representing values from a specific motion axis (gyroX, AccY, etc)
@property(nonatomic, readonly) BDMotionManagerSensorType sensorType;
@property(nonatomic, readonly) float peakValue;
@property(nonatomic, readonly) BDMotionManagerMotionType motionType;

/**
 * Returns a BDDataSegment instance for the given sensorType and array of BDLocData objects
 * @param segmentArray An arary of BDLocData objects
 * @param sensorType The type of sensor that this segment represents
 * @return A BDDataSegment instance
 */
+ (instancetype _Nullable)initWithSegmentData:(NSArray *_Nonnull)segmentArray andSensorType:(BDMotionManagerSensorType)sensorType;

/**
 * Updates the BDDataSegment obect with the given sensorType and array of BDLocData objects
 * @param segmentArray An arary of BDLocData objects
 * @param sensorType The type of sensor that this segment represents
 */
- (void)updateWithSegmentData:(NSArray *_Nonnull)segmentArray andSensorType:(BDMotionManagerSensorType)sensorType;

@end

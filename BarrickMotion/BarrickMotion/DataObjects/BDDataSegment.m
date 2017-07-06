//
//  BDDataSegment.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-06-29.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDDataSegment.h"
#import "BDLocData.h"

@implementation BDDataSegment {
    float _peakValue;
}

+ (instancetype _Nullable)initWithSegmentData:(NSArray *_Nonnull)segmentArray andSensorType:(BDMotionManagerSensorType)sensorType {
    BDDataSegment *dataObj = [[BDDataSegment alloc] init];
    [dataObj updateWithSegmentData:segmentArray andSensorType:sensorType];
    return dataObj;
}

- (void)updateWithSegmentData:(NSArray *_Nonnull)segmentArray andSensorType:(BDMotionManagerSensorType)sensorType {
    // Store the segment array and type
    _segmentData = segmentArray;
    _sensorType = sensorType;
    _peakValue = 0;
    
    // Loop through values and find the peak value
    for (BDLocData *locObj in segmentArray) {
        float currVal = [locObj valueForSensorType:sensorType];
        // Compare the absolute values, but ignore sign when assigning to the instance variable
        if (ABS(currVal) > ABS(_peakValue)) {
            _peakValue = currVal;
        }
    }
    
    // Figure out the motion type based on the peak value and the sensor type
    switch (sensorType) {
        case BDMotionManagerSensorTypeGyroX:
            _motionType = BDMotionManagerMotionTypeBaseline; // Just assume baseline for now
            break;
        case BDMotionManagerSensorTypeGyroY: {
            if (_peakValue > 0) {
                _motionType = BDMotionManagerMotionTypeTurnLeft;
            } else {
                _motionType = BDMotionManagerMotionTypeTurnRight;
            }
            break;
        }
        case BDMotionManagerSensorTypeGyroZ:
            _motionType = BDMotionManagerMotionTypeBaseline; // Just assume baseline for now
            break;
        case BDMotionManagerSensorTypeAccX:
            _motionType = BDMotionManagerMotionTypeBaseline; // Just assume baseline for now
            break;
        case BDMotionManagerSensorTypeAccY:
            _motionType = BDMotionManagerMotionTypeBump;
            break;
        case BDMotionManagerSensorTypeAccZ:{
            if (_peakValue > 0) {
                _motionType = BDMotionManagerMotionTypeAcceleration;
            } else {
                _motionType = BDMotionManagerMotionTypeStopping;
            }
            break;
        }
        default:
            break;
    }
}

- (float)peakValue {
    return _peakValue;
}

@end

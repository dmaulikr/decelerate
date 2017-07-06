//
//  BDDataPacket.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDDataPacket.h"

@implementation BDDataPacket

- (instancetype)init {
    if(self = [super init]) {
        self.violation = BDMotionManagerViolationTypeNone; // Set this to nothing by default
    }
    return self;
}

- (float)valueForSensorType:(BDMotionManagerSensorType)sensorType {
    float currVal = 0;
    switch (sensorType) {
        case BDMotionManagerSensorTypeGyroX:
            currVal = _rotationData.x;
            break;
        case BDMotionManagerSensorTypeGyroY:
            currVal = _rotationData.y;
            break;
        case BDMotionManagerSensorTypeGyroZ:
            currVal = _rotationData.z;
            break;
        case BDMotionManagerSensorTypeAccX:
            currVal = _accelerometerData.x;
            break;
        case BDMotionManagerSensorTypeAccY:
            currVal = _accelerometerData.y;
            break;
        case BDMotionManagerSensorTypeAccZ:
            currVal = _accelerometerData.z;
            break;
        default:
            break;
    }
    return currVal;
}

@end

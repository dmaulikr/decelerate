//
//  BDDataPacket.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "BDMotionManager.h"

/**
 * Represents a collection of sensor data associated wth the last received location and current timestamp
 */
@interface BDDataPacket : NSObject

@property (nonatomic, readwrite) CMAcceleration accelerometerData;
@property (nonatomic, readwrite) CMRotationRate rotationData;
//@property (nonatomic, nullable, strong) CMMagnetometerData *magData;
@property (nonatomic, nullable, strong) CLLocation *location;
@property (nonatomic, nullable, strong) NSString *driverID;
@property (nonatomic, nullable, strong) NSString *routeID;
@property (nonatomic, nullable, strong) NSString *tripID;
@property (nonatomic, readwrite) BDMotionManagerViolationType violation;
@property (nonatomic, nullable, strong) NSString *timestamp;

/**
 * The value of the sensor data for the given type
 * @param sensorType The enum value representing the sensor for desired value
 * @return The value for the requested sensor
 */
- (float)valueForSensorType:(BDMotionManagerSensorType)sensorType;

@end

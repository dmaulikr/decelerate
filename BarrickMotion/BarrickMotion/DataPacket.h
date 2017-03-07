//
//  DataPacket.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface DataPacket : NSObject

@property (nonatomic, nullable, strong) CMAccelerometerData* accelerometerData;
@property (nonatomic, nullable, strong) CMGyroData *gyroData;
@property (nonatomic, nullable, strong) CMMagnetometerData *magData;
@property (nonatomic, nullable, strong) CLLocation *location;
@property (nonatomic, nullable, strong) NSString *driverID;
@property (nonatomic, nullable, strong) NSString *sensorID;
@property (nonatomic, nullable, strong) NSString *load;


@end

//
//  DataObject3D.h
//  MotionAnalytics
//
//  Created by Kevin Hunt on 2017-03-05.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataObject3D : NSObject

@property (nonatomic, nullable, strong) NSDictionary *sensorLeft;
@property (nonatomic, nullable, strong) NSDictionary *sensorRight;
@property (nonatomic) float averageAccX;
@property (nonatomic) float averageAccY;
@property (nonatomic) float averageAccZ;
@property (nonatomic) float averageGyroX;
@property (nonatomic) float averageGyroY;
@property (nonatomic) float averageGyroZ;
@property (nonatomic) float averageSpeed;
@property (nonatomic, nullable, strong) NSDate *timestamp;

@end

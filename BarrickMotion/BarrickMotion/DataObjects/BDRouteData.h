//
//  BDRouteData.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-07-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 * Represents the metadata values of a specific route
 */
@interface BDRouteData : NSObject

@property (nonatomic, nullable, strong) NSString *routeID;
@property (nonatomic, nullable, strong) NSString *routeName;
@property (nonatomic, nullable, strong) CLLocation *routeStartLocation;
@property (nonatomic, nullable, strong) CLLocation *routeEndLocation;
@property (nonatomic, nullable, strong) NSString *routeStartAddressString;

/**
 * Returns a BDRouteData instance for the dictionary of values
 * @param dict An dictionary of values and keys representing the metadata properties of the BDRouteData class
 * @return A BDRouteData instance
 */
- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull)dict;

@end

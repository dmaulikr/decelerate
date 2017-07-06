//
//  BDRouteData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-07-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDRouteData.h"
#import "BDConstants.h"

@implementation BDRouteData

- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        _routeID = [dict objectForKey:BDLocDataRouteIDKey];
        _routeName = [dict objectForKey:BDRouteDataNameKey];
        
        // Generate the CLLocation objects from the float value in the dict
        float startLocLon = [[dict objectForKey:BDRouteDataStartLocLonKey] floatValue];
        float startLocLat = [[dict objectForKey:BDRouteDataStartLocLatKey] floatValue];
        float endLocLon = [[dict objectForKey:BDRouteDataEndLocLonKey] floatValue];
        float endLocLat = [[dict objectForKey:BDRouteDataEndLocLatKey] floatValue];
        
        _routeStartLocation = [[CLLocation alloc] initWithLatitude:startLocLat longitude:startLocLon];
        _routeEndLocation = [[CLLocation alloc] initWithLatitude:endLocLat longitude:endLocLon];
        
        return self;
    }
    return nil;
}

- (NSString *_Nullable)routeStartAddressString {
    if (_routeStartAddressString && [_routeStartAddressString length] > 0) {
        return _routeStartAddressString;
    } else {
        // TODO: Use Google reverse Geo API to find address from GPS coords
        
        return nil;
    }
}

@end

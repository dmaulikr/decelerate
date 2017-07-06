//
//  BDTripData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDTripData.h"

@implementation BDTripData

- (instancetype _Nullable )initWithDictionary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        _driverID = [dict objectForKey:BDLocDataDriverIDKey];
        _routeID = [dict objectForKey:BDLocDataRouteIDKey];
        _tripID = [dict objectForKey:BDLocDataTripIDKey];
        _timestamp = [dict objectForKey:BDTripDataTimestampKey];
        _load = [dict objectForKey:BDTripDataLoadKey];
        _score = [dict objectForKey:BDTripDataScoreKey];
        
        // Create date and time values from the timestamp
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateTime = [dateFormatter dateFromString:_timestamp];
        
        [dateFormatter setDateFormat:@"hh:mm a"];
        _time = [dateFormatter stringFromDate:dateTime];
        
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        _date = [dateFormatter stringFromDate:dateTime];
        
        // Create the route object from the remaining properties in the dict
        _routeObj = [[BDRouteData alloc] initWithDictionary:dict];
        
        return self;
    }
    return nil;
}

@end

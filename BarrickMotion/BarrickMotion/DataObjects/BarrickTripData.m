//
//  BarrickTripData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BarrickTripData.h"

NSString *const BarrickLocalTripDateKey     = @"date";
NSString *const BarrickLocalTripTimeKey     = @"time";
NSString *const BarrickLocalTripAddressKey  = @"address";
NSString *const BarrickLocalTripScoreKey    = @"score";

@implementation BarrickTripData

- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        self.date = [dict objectForKey:BarrickLocalTripDateKey];
        self.time = [dict objectForKey:BarrickLocalTripTimeKey];
        self.address = [dict objectForKey:BarrickLocalTripAddressKey];
        self.score = [dict objectForKey:BarrickLocalTripScoreKey];
        return self;
    }
    return nil;
}

@end

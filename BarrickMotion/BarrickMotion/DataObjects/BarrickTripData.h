//
//  BarrickTripData.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const BarrickLocalTripDateKey;
OBJC_EXTERN NSString *const BarrickLocalTripTimeKey;
OBJC_EXTERN NSString *const BarrickLocalTripAddressKey;
OBJC_EXTERN NSString *const BarrickLocalTripScoreKey;

@interface BarrickTripData : NSObject

@property (nonatomic, nullable, strong) NSString *date;
@property (nonatomic, nullable, strong) NSString *time;
@property (nonatomic, nullable, strong) NSString *address;
@property (nonatomic, nullable, strong) NSString *score;

- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict;

@end

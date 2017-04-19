//
//  BarrickRankingData.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const BarrickLocalRankingRankKey;
OBJC_EXTERN NSString *const BarrickLocalRankingNameKey;
OBJC_EXTERN NSString *const BarrickLocalRankingStarsKey;
OBJC_EXTERN NSString *const BarrickLocalRankingScoreKey;

@interface BarrickRankingData : NSObject

@property (nonatomic, nullable, strong) NSString *ranking;
@property (nonatomic, nullable, strong) NSString *name;
@property (nonatomic, nullable, strong) NSString *stars;
@property (nonatomic, nullable, strong) NSString *score;

- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict;


@end

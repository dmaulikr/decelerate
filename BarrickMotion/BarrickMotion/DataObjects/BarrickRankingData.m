//
//  BarrickRankingData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BarrickRankingData.h"

NSString *const BarrickLocalRankingRankKey     = @"rank";
NSString *const BarrickLocalRankingNameKey     = @"name";
NSString *const BarrickLocalRankingStarsKey    = @"stars";
NSString *const BarrickLocalRankingScoreKey    = @"score";


@implementation BarrickRankingData

- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        self.ranking = [dict objectForKey:BarrickLocalRankingRankKey];
        self.name = [dict objectForKey:BarrickLocalRankingNameKey];
        self.stars = [dict objectForKey:BarrickLocalRankingStarsKey];
        self.score = [dict objectForKey:BarrickLocalRankingScoreKey];
        return self;
    }
    return nil;
}


@end

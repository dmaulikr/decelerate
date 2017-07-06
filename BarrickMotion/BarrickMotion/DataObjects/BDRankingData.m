//
//  BDRankingData.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDRankingData.h"


@implementation BDRankingData

- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict {
    if (self = [super init]) {
        self.driverID = [dict objectForKey:BDTRankingDataDriverIDKey];
        self.ranking = [dict objectForKey:BDTRankingDataRankKey];
        self.name = [dict objectForKey:BDTRankingDataNameKey];
        self.stars = [dict objectForKey:BDTRankingDataStarsKey];
        self.score = [dict objectForKey:BDTRankingDataScoreKey];
        return self;
    }
    return nil;
}


@end

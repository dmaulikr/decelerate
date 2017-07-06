//
//  BarrickDataManager.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDDataManager.h"
#import "BDTripData.h"
#import "BDRankingData.h"

@implementation BDDataManager {
    NSArray *_tripDataArray;
    NSArray *_rankDataArray;
}

static BDDataManager *_sharedDataManager;

+ (instancetype)sharedDataManager {
    @synchronized([BDDataManager class]) {
        if(!_sharedDataManager) {
            NSLog(@"Creating Data Manager");
            _sharedDataManager  = [[BDDataManager alloc] init];
        }
        return _sharedDataManager;
    }
    return nil;
}

- (void)initializeWithServer {
    // TODO: Setup CoreData storage
}

// TESTING ONLY
- (void)initializeWithLocalData {
    
    // Initialize the trip data from a local JSON file
    NSString *tripDataPath = [[NSBundle mainBundle] pathForResource:@"TripData" ofType:@"json"];
    NSData *tripData = [NSData dataWithContentsOfFile:tripDataPath];
    NSError *jsonError = nil;
    NSDictionary *parsedTripDict = [NSJSONSerialization JSONObjectWithData:tripData options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"JSON parsing error: %@", jsonError);
        return;
    }
    
    NSMutableArray *mutableTripArray = [NSMutableArray array];
    
    for (NSDictionary *tripDict in [parsedTripDict objectForKey:@"tripData"]) {
        BDTripData *tripDataObj = [[BDTripData alloc] initWithDictionary:tripDict];
        if (tripDataObj) {
            [mutableTripArray addObject:tripDataObj];
        }
    }
    
    _tripDataArray = [NSArray arrayWithArray:mutableTripArray];
    
    
    
    // Initialize the ranking data from a local JSON file
    NSString *rankDataPath = [[NSBundle mainBundle] pathForResource:@"RankingData" ofType:@"json"];
    NSData *rankData = [NSData dataWithContentsOfFile:rankDataPath];
    NSDictionary *parsedRankDict = [NSJSONSerialization JSONObjectWithData:rankData options:0 error:&jsonError];
    if (jsonError) {
        NSLog(@"JSON parsing error: %@", jsonError);
        return;
    }
    
    NSMutableArray *mutableRankArray = [NSMutableArray array];
    
    for (NSDictionary *rankDict in [parsedRankDict objectForKey:@"rankData"]) {
        BDRankingData *rankDataObj = [[BDRankingData alloc] initWithDictionsary:rankDict];
        if (rankDataObj) {
            [mutableRankArray addObject:rankDataObj];
        }
    }
    
    _rankDataArray = [NSArray arrayWithArray:mutableRankArray];
}

- (NSArray *)tripData {
    return _tripDataArray;
}

- (NSArray *)rankData {
    return _rankDataArray;
}

@end

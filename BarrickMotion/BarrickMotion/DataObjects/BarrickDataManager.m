//
//  BarrickDataManager.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BarrickDataManager.h"
#import "BarrickTripData.h"
#import "BarrickRankingData.h"

@implementation BarrickDataManager {
    NSArray *_tripDataArray;
    NSArray *_rankDataArray;
}

static BarrickDataManager *_sharedDataManager;

+ (instancetype)sharedDataManager {
    @synchronized([BarrickDataManager class]) {
        if(!_sharedDataManager) {
            NSLog(@"Creating Data Manager");
            _sharedDataManager  = [[BarrickDataManager alloc] init];
        }
        
        NSLog(@"Returning shared Data Manager");
        return _sharedDataManager;
    }
    
    return nil;
}

- (void)initializeWithServer {
    
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
        BarrickTripData *tripDataObj = [[BarrickTripData alloc] initWithDictionsary:tripDict];
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
        BarrickRankingData *rankDataObj = [[BarrickRankingData alloc] initWithDictionsary:rankDict];
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

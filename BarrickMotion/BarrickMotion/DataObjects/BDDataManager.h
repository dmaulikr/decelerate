//
//  BarrickDataManager.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDDataManager.h"

/* 
 * Currently storing and retrieving local "mock data" for UI
 * @note This will be refactored to handle CoreData storage/retrieval when there is more time
 */
@interface BDDataManager : NSObject

/**
 * Returns the shared manager instance
 */
+ (instancetype)sharedDataManager;

/**
 * Starts the shared data manager by loading local TEST values from a JSON file
 */
- (void)initializeWithLocalData;

/**
 * Starts the shared data manager by loading locally stored CoreData values
 */
- (void)initializeWithServer;

/**
 * Returns all locally stored trip data
 * @return An array of BDTripData objects
 */
- (NSArray *)tripData;

/**
 * Returns all locally stored ranking data
 * @return An array of BDRankingData objects
 */
- (NSArray *)rankData;

@end

//
//  BDRankingData.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDConstants.h"

/**
 * Represents the sitewide ranking values of a given driver
 */
@interface BDRankingData : NSObject

@property (nonatomic, nullable, strong) NSString *driverID;
@property (nonatomic, nullable, strong) NSString *ranking;
@property (nonatomic, nullable, strong) NSString *name;
@property (nonatomic, nullable, strong) NSString *stars;
@property (nonatomic, nullable, strong) NSString *score;

/**
 * Returns a BDRankingData instance for the dictionary of values
 * @param dict An dictionary of values and keys representing the metadata properties of the BDRankingData class
 * @return A BDRankingData instance
 */
- (instancetype _Nullable )initWithDictionsary:(NSDictionary *_Nonnull)dict;


@end

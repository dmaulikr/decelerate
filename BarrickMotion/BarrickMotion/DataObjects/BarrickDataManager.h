//
//  BarrickDataManager.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BarrickDataManager.h"

@interface BarrickDataManager : NSObject

+ (instancetype)sharedDataManager;
- (void)initializeWithLocalData;
- (void)initializeWithServer;

- (NSArray *)tripData;
- (NSArray *)rankData;

@end

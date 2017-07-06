//
//  BDServerDataManager.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDDataPacket.h"
#import "BDTripData.h"
#import "BDRouteData.h"

/** 
 * Callback function for retrieval of BDLocData objects
 * @note If error is not nil, the request is assumed to have failed
 * @param locDataArray An array of BDLocData objects
 * @param error An NSError object representing the error encountered while retrieving the data
 */
typedef void(^BDMasterDataRequestCompleted)(NSArray * _Nullable locDataArray, NSError * _Nullable error);

/**
 * Callback function for retrieval of BDTripData objects
 * @note If error is not nil, the request is assumed to have failed
 * @param tripDataArray An array of BDTripData objects
 * @param error An NSError object representing the error encountered while retrieving the data
 */
typedef void(^BDTripDataRequestCompleted)(NSArray * _Nullable tripDataArray, NSError * _Nullable error);

/**
 * Callback function for retrieval of a BDRouteData object
 * @note If error is not nil, the request is assumed to have failed
 * @param routeData A BDRouteData object returned by the server
 * @param error An NSError object representing the error encountered while retrieving the data
 */
typedef void(^BDRouteDataRequestCompleted)(BDRouteData * _Nullable routeData, NSError * _Nullable error);



/**
 * Handles sending data packets to the server as well as retrieving route/trip information and processing it into usable objects
 */
@interface BDServerDataManager : NSObject

/**
 * Returns the shared manager instance
 */
+ (instancetype _Nullable )sharedDataManager;

@property (nonatomic, nullable, strong) NSString *driverID;
@property (nonatomic, nullable, strong) NSString *routeID;
@property (nonatomic, nullable, strong) NSString *routeName;
@property (nonatomic, readwrite) BOOL isMasterRecording;


/**
 * The tripID that will be used for the current trip or trip that is about to be started
 * @note This will always be "MASTER" if isMasterRecording is true
 * @return A string representig the current/next tripID
 */
- (NSString *_Nonnull)currentTripID;
/**
 * Retrieves the tripID that will be used for the trip that is about to be started and stores the incremented value
 * @note This will always be "MASTER" if isMasterRecording is true
 * @return A string representig the current tripID
 */
- (NSString *_Nonnull)updateCurrentTripID;

/**
 * Sends the sensor, location, and timestamp data to the server
 * @param dataPacket A BDDataPacket object representing the values to be sent to the server
 */
- (void)sendLocData:(BDDataPacket *_Nonnull)dataPacket;

/**
 * Sends the trip metadata to be stored by the server
 * @param tripData A BDTripData object representing the values to be sent to the server
 */
- (void)sendTripData:(BDTripData *_Nonnull)tripData;

/**
 * Sends the route metadata to be stored by the server
 * @param routeData A BDRouteData object representing the values to be sent to the server
 */
- (void)sendRouteData:(BDRouteData *_Nonnull)routeData;

/**
 * Retrieves a list of BDLocData objects corresponding to a given tripID and routeID
 * @param tripID A string representing the tripID for which the data should belong to
 * @param routeID A string representing the tripID for which the data should also belong to
 * @param callback A callback block to be executed when the request has finished
 */
- (void)getLocationDataForTripID:(NSString *_Nonnull)tripID forRouteID:(NSString *_Nonnull)routeID withCallback:(BDMasterDataRequestCompleted _Nullable )callback;

/**
 * Retrieves a list of BDTripData objects corresponding to a given driverID
 * @param driverID A string representing the driverID for which the data should belong to
 * @param callback A callback block to be executed when the request has finished
 */
- (void)getTripDataForDriverID:(NSString *_Nonnull)driverID withCallback:(BDTripDataRequestCompleted _Nullable )callback;

/**
 * Retrieves a BDRouteData object corresponding to a given routeID
 * @param routeID A string representing the driverID for which the data should belong to
 * @param callback A callback block to be executed when the request has finished
 */
- (void)getRouteDataForRouteID:(NSString *_Nonnull)routeID withCallback:(BDRouteDataRequestCompleted _Nullable )callback;

@end

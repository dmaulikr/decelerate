//
//  BDServerDataManager.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-05-31.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "BDServerDataManager.h"
#import "Reachability.h"
#import "BDTripData.h"
#import "BDLocData.h"
#import <CoreLocation/CoreLocation.h>

#define kServerUrl @"http://kevinjameshunt.com/barrick"
#define kPostLocation @"submitBarrickLoc.php"
#define kGetTrip @"getBarrickTripData.php"
#define kGetTrips @"getBarrickTripsList.php"
#define kPostTrip @"submitBarrickTrip.php"
#define kPostRoute @"submitBarrickRoute.php"

#define kMovementDataArray @"movementData"
#define kTripDataArray @"tripData"
#define kDefaultTestDriverID    @"TestDriver1"
#define kDefaultTestRouteID     @"HomeTest1"
#define kDefaultTestRouteName   @"Tests At Home"

@implementation BDServerDataManager {
    BDDataPacket *_currentPacket;
    NSMutableDictionary *_masterTrips; // Keys are routeIDs
}

static BDServerDataManager *_sharedDataManager;

+ (instancetype)sharedDataManager {
    @synchronized([BDServerDataManager class]) {
        if(!_sharedDataManager) {
            NSLog(@"Creating Server Data Manager");
            _sharedDataManager  = [[BDServerDataManager alloc] init];
        }
        return _sharedDataManager;
    }
    return nil;
}

- (instancetype)init {
    if(self = [super init]) {
        self.routeID = kDefaultTestRouteID;
        self.routeName = kDefaultTestRouteName;
        self.driverID = kDefaultTestDriverID;
        self.isMasterRecording = NO;
    }
    return self;
}

- (NSString *)currentTripID {
    // If we are about to set a master recoring, always return MASTER
    if (self.isMasterRecording) {
        return BDTripDataMASTERKey;
    } else {
        NSInteger tripIDCount = [[[NSUserDefaults standardUserDefaults] objectForKey:_driverID] integerValue];
        // Return the next value that will be used when the next trip starts
        tripIDCount ++;
        return [NSString stringWithFormat:@"%@-%ld", _driverID, (long)tripIDCount];
    }
}

- (NSString *)updateCurrentTripID {
    // If we are about to set a master recoring, always return MASTER
    if (self.isMasterRecording) {
        return BDTripDataMASTERKey;
    } else {
        // Increment the value and save it
        NSInteger tripIDCount = [[[NSUserDefaults standardUserDefaults] objectForKey:_driverID] integerValue];
        tripIDCount ++;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tripIDCount] forKey:_driverID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Return the new tripID
        NSString *newTripID = [NSString stringWithFormat:@"%@-%ld", _driverID, (long)tripIDCount];
        return newTripID;
    }
}

- (void)sendLocData:(BDDataPacket *)dataPacket {
    _currentPacket = dataPacket;
    
    if (_currentPacket != nil &&
        _currentPacket.location != nil &&
        //        _currentPacket.accelerometerData != nil &&
        //        _currentPacket.gyroData != nil &&
        //        _currentPacket.magData != nil &&
        _currentPacket.driverID != nil &&
        _currentPacket.routeID != nil &&
        _currentPacket.tripID != nil) {
        
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        { //connection unavailable
            NSLog(@"Unable to post data packet to server because network is not reachable");
            // TODO: Store this data to be posted when network is available
            
        } else { //connection available
            
            // Construct request URL
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerUrl, kPostLocation]];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.HTTPAdditionalHeaders = @{@"Content-Type"  : @"application/json",
                                             @"Accept"  : @"application/json" };
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            
            // Construct the data dictionary for POST
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        _currentPacket.driverID, BDLocDataDriverIDKey,
                                        _currentPacket.routeID, BDLocDataRouteIDKey,
                                        _currentPacket.tripID, BDLocDataTripIDKey,
                                        [NSNumber numberWithInt:_currentPacket.violation], BDLocDataViolationKey,
                                        [NSNumber numberWithFloat:_currentPacket.location.coordinate.longitude], BDLocDataLongKey,
                                        [NSNumber numberWithFloat:_currentPacket.location.coordinate.latitude], BDLocDataLatKey,
                                        [NSNumber numberWithFloat:_currentPacket.accelerometerData.x], BDLocDataAccXKey,
                                        [NSNumber numberWithFloat:_currentPacket.accelerometerData.y], BDLocDataAccYKey,
                                        [NSNumber numberWithFloat:_currentPacket.accelerometerData.z], BDLocDataAccZKey,
                                        [NSNumber numberWithFloat:_currentPacket.rotationData.x], BDLocDataGyroXKey,
                                        [NSNumber numberWithFloat:_currentPacket.rotationData.y], BDLocDataGyroYKey,
                                        [NSNumber numberWithFloat:_currentPacket.rotationData.z], BDLocDataGyroZKey,
                                        nil];
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:kNilOptions error:&error];
            
            if (!error) {
                // Create and start the data task
                NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                    if (error) {
                        // If the was an error
                        NSLog(@"sendLocData error:,%@", [error localizedDescription]);
                    } else {
                        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"sendLocData server response: \n%@", returnString);
                    }
                }];
                [task resume];
            } else {
                NSLog(@"Error creating packet dictionary for POST reqest:,%@", [error localizedDescription]);
            }
        }
    } else {
        NSLog(@"Packet not ready to send");
    }
}

- (void)sendTripData:(BDTripData *_Nonnull)tripData {
    if (tripData.driverID && [tripData.driverID length] > 0 &&
        tripData.tripID && [tripData.tripID length] > 0 &&
        tripData.routeID && [tripData.routeID length] > 0 &&
        tripData.score && [tripData.score length] > 0 &&
        tripData.load && [tripData.load length] > 0) {
        
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        { //connection unavailable
            NSLog(@"Unable to post trip data to server because network is not reachable");
            // TODO: Store this data to be posted when network is available
            
        } else { //connection available
            
            // Construct request URL
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerUrl, kPostTrip]];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.HTTPAdditionalHeaders = @{@"Content-Type"  : @"application/json",
                                             @"Accept"  : @"application/json" };
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            
            // Construct the data dictionary for POST
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        tripData.driverID, BDLocDataDriverIDKey,
                                        tripData.routeID, BDLocDataRouteIDKey,
                                        tripData.tripID, BDLocDataTripIDKey,
                                        tripData.score, BDTripDataScoreKey,
                                        tripData.load, BDTripDataLoadKey,
                                        nil];
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:kNilOptions error:&error];
            
            if (!error) {
                // Create and start the data task
                NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                    if (error) {
                        // If the was an error
                        NSLog(@"sendTripData error:,%@", [error localizedDescription]);
                    } else {
                        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"sendTripData server response: \n%@", returnString);
                    }
                }];
                [task resume];
            } else {
                NSLog(@"Error creating trip dictionary for POST reqest:,%@", [error localizedDescription]);
            }
        }
    } else {
        NSLog(@"trip data not ready to send");
    }
}

- (void)sendRouteData:(BDRouteData *_Nonnull)routeData {
    if (routeData.routeID && [routeData.routeID length] > 0 &&
        routeData.routeName && [routeData.routeName length] > 0 &&
        routeData.routeStartLocation != nil && routeData.routeEndLocation != nil) {
        
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        { //connection unavailable
            NSLog(@"Unable to post route data to server because network is not reachable");
            // TODO: Store this data to be posted when network is available
            
        } else { //connection available
            
            // Construct request URL
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerUrl, kPostRoute]];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.HTTPAdditionalHeaders = @{@"Content-Type"  : @"application/json",
                                             @"Accept"  : @"application/json" };
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"POST";
            
            // Construct the data dictionary for POST
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        routeData.routeID, BDLocDataRouteIDKey,
                                        routeData.routeName, BDRouteDataNameKey,
                                        [NSNumber numberWithFloat:routeData.routeStartLocation.coordinate.longitude], BDRouteDataStartLocLonKey,
                                        [NSNumber numberWithFloat:routeData.routeStartLocation.coordinate.latitude], BDRouteDataStartLocLatKey,
                                        [NSNumber numberWithFloat:routeData.routeEndLocation.coordinate.longitude], BDRouteDataEndLocLonKey,
                                        [NSNumber numberWithFloat:routeData.routeEndLocation.coordinate.latitude], BDRouteDataEndLocLatKey,
                                        nil];
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:kNilOptions error:&error];
            
            if (!error) {
                // Create and start the data task
                NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                    if (error) {
                        // If the was an error
                        NSLog(@"sendRouteData error:,%@", [error localizedDescription]);
                    } else {
                        NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSLog(@"sendRouteData server response: \n%@", returnString);
                    }
                }];
                [task resume];
            } else {
                NSLog(@"Error creating route dictionary for POST reqest:,%@", [error localizedDescription]);
            }
        }
    } else {
        NSLog(@"route data not ready to send");
    }
}

- (void)getLocationDataForTripID:(NSString *_Nonnull)tripID forRouteID:(NSString *_Nonnull)routeID withCallback:(BDMasterDataRequestCompleted _Nullable )callback {
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    { //connection unavailable
        NSLog(@"Unable to call getTripDataForTripID because network is not reachable");
        
    } else { //connection available
        
        // Construct request URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerUrl, kGetTrip]];
        NSString *paramString = [NSString stringWithFormat:@"%@=%@&%@=%@", BDLocDataTripIDKey, tripID, BDLocDataRouteIDKey, routeID];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
        
        // Create and start the data task
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // If there is an error in the response object
            if (error) {
                // If the was an error, dont bother trying to update, we can try the next time the app is run
                NSLog(@"getTripDataForTripID error:,%@", [error localizedDescription]);
                callback(nil, error);
                return;
            }
            
            // Process the data and update the database
            // ========================================
            
            // Parse the JSON response
            NSError *readError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&readError];
            if (readError != nil) {
                callback(nil, readError);
                return;
            }
            
            // Retrieve object list from responseDict
            NSArray *objectArray = responseDict[kMovementDataArray];
            
            // If we have an array of items
            if (objectArray && [objectArray count] > 0) {
                
                // Create the TripData object
                // TODO: this should come seperately from the server
//                BDTripData *tripDataObj = [[BDTripData alloc] initWithDictionary:[objectArray objectAtIndex:0]];
                
                // Loop through and process each object, then save it in the DataManager
                NSMutableArray *locObjArray = [NSMutableArray arrayWithCapacity:[objectArray count]];
                for (NSDictionary *objectDict in objectArray) {
                    BDLocData *locDataObj = [[BDLocData alloc] initWithDictionary:objectDict];
                    [locObjArray addObject:locDataObj];
                }
                
                // Return the list of location objects
                NSLog(@"getTripDataForTripID processing Complete");
                callback([NSArray arrayWithArray:locObjArray], nil);
                
            } else { // Return an error if there are no objects
                NSError *objectError = [NSError errorWithDomain:@"BarickMotion" code:501001 userInfo:nil];
                callback(nil, objectError);
                return;
            }
        }];
        [task resume];
    }
}

- (void)getTripDataForDriverID:(NSString *_Nonnull)driverID withCallback:(BDTripDataRequestCompleted _Nullable )callback {
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    { //connection unavailable
        NSLog(@"Unable to call getTripDataForTripID because network is not reachable");
        
    } else { //connection available
        
        // Construct request URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerUrl, kGetTrips]];
        NSString *paramString = [NSString stringWithFormat:@"%@=%@", BDLocDataDriverIDKey, driverID];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPMethod = @"POST";
        
        // Create and start the data task
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // If there is an error in the response object
            if (error) {
                // If the was an error, dont bother trying to update, we can try the next time the app is run
                NSLog(@"getTripDataForDriverID error:,%@", [error localizedDescription]);
                callback(nil, error);
                return;
            }
            
            // Process the data and update the database
            // ========================================
            
            // Parse the JSON response
            NSError *readError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&readError];
            if (readError != nil) {
                callback(nil, readError);
                return;
            }
            
            // Retrieve object list from responseDict
            NSArray *objectArray = responseDict[kTripDataArray];
            
            // If we have an array of items
            if (objectArray && [objectArray count] > 0) {
                
                // Loop through and process each object, then save it in the DataManager
                NSMutableArray *tripObjArray = [NSMutableArray arrayWithCapacity:[objectArray count]];
                for (NSDictionary *objectDict in objectArray) {
                    BDTripData *tripDataObj = [[BDTripData alloc] initWithDictionary:objectDict];
                    [tripObjArray addObject:tripDataObj];
                }
                
                // Return the list of location objects
                NSLog(@"getTripDataForDriverID processing Complete");
                callback([NSArray arrayWithArray:tripObjArray], nil);
                
            } else { // Return an error if there are no objects
                NSError *objectError = [NSError errorWithDomain:@"BarickMotion" code:501002 userInfo:nil];
                callback(nil, objectError);
                return;
            }
        }];
        [task resume];
    }
}

- (void)getRouteDataForRouteID:(NSString *_Nonnull)routeID withCallback:(BDRouteDataRequestCompleted _Nullable )callback {
    
}

@end

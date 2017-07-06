//
//  BDAnnotatedMapView.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2014-12-01.
//  Copyright (c) 2014 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKAnnotationView.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
#import "CSRouteAnnotation.h"
#import "CSRouteView.h"
#import "BDConstants.h"

/**
 * The View containing an MKMapView and annotations (pins, route drawings, etc)
 */
@interface BDAnnotatedMapView : UIView <MKMapViewDelegate,  CLLocationManagerDelegate, UINavigationControllerDelegate>

@property (retain, nonatomic) IBOutlet MKMapView *mkMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;       // The location manager
@property (nonatomic) CLLocationAccuracy locationAccuracy;
@property (nonatomic) CLLocationCoordinate2D  userLocation;
@property (nonatomic, retain) MKUserLocation *userLocAnnotation;
@property (nonatomic, strong) CLGeocoder *geocoder;                     // The geocoder

@property (nonatomic, retain) CSRouteAnnotation *       routeAnnotation;
@property (nonatomic, retain) CSRouteView *             theRouteView;
@property (nonatomic) bool                              isPolling;
@property (nonatomic) bool                              isUpdatingLocation;
@property (nonatomic, strong) NSArray *locationAnnotations;

/**
 * Initializes the mapView
 * @param locDataArray An array of BDLocData objects
 */
- (void)setupMapViewWithLocData:(NSArray *)locDataArray;

/**
 * Refreshes the mapView using its current data
 */
- (void)updateMapView;

/**
 * Centers the map on the users current location
 */
- (void)centerOnUserLoc;

@end

/**
 * Object representing the data required to create an annotation view on the map
 */
@interface LocationAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D  coordinate;
    CLLocation *            theLocation;
    NSString *              mTitle;
    NSString *              mSubTitle;
    
}

@property (nonatomic, retain) NSString *    mTitle;
@property (nonatomic, retain) NSString *    mSubTitle;
@property (nonatomic, retain) CLLocation *  theLocation;
@property (nonatomic) BDAnnotationType annotationType;

@end

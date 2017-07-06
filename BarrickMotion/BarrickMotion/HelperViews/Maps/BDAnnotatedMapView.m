//
//  BDAnnotatedMapView.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2014-12-01.
//  Copyright (c) 2014 Prophet Studios. All rights reserved.
//

#import "BDAnnotatedMapView.h"
#import "BDLocData.h"

@implementation LocationAnnotation

@synthesize coordinate, mSubTitle, mTitle, theLocation, annotationType;

- (NSString *)subtitle{
    return mSubTitle;
}

- (NSString *)title{
    return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}

@end

@implementation BDAnnotatedMapView {
    NSArray *_locDataArray;
    
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setupMapViewWithLocData:(NSArray *)locDataArray {
    
    _locDataArray = locDataArray;
    
    // This will force the location alert to appear when the view is loaded
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //  requestWhenInUseAuthorization is only available on iOS 8
    //  Make sure you also modify the application info.plist to include a NSLocationWhenInUseUsageDescription string
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
        
    }
    
    // Start monitoring location for the map
    self.isUpdatingLocation = YES;
    [self.locationManager startUpdatingLocation];
    
    // Set starting params of MKMapView
    self.mkMapView.delegate = self;
    self.mkMapView.showsUserLocation = NO;
    [self.mkMapView setMapType:MKMapTypeStandard];
    [self.mkMapView setZoomEnabled:YES];
    [self.mkMapView setScrollEnabled:YES];
    
    // Remove all annotations if any existed before
    [self.mkMapView removeAnnotations:[self.mkMapView annotations]];
    
    // Create thew new annotations
    [self setupRouteAnnotation];
    
}

-(void)updateMapView {
    
    // Refresh location manager properties
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    NSLog(@"%@", [self deviceLocation]);
    
    // Update the map area to be displayed in the view
    MKCoordinateRegion region = self.mkMapView.region;
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [self.mkMapView setRegion:region animated:YES];
    
    // Remove all annotations
    [self.mkMapView removeAnnotations:[self.mkMapView annotations]];
    
    // Remove the route annotation from the map
    if (self.routeAnnotation) {
        [self.mkMapView removeAnnotation:self.routeAnnotation];
        self.routeAnnotation = nil;
    }
    
    // Setup the route annotation
    [self setupRouteAnnotation];
    
    // Add the data points
    if (_locDataArray && [_locDataArray count] >0) {
        // cycle through and add all data objects
        for (BDLocData *locObj in _locDataArray) {
            
            // Only create a pin if it is for a violation
            if (locObj.violation > BDMotionManagerViolationTypeNone) {
                // Get the location and create pin for map
                CLLocation *theLocation = [[CLLocation alloc] initWithLatitude:locObj.latitude longitude:locObj.longitude];
                LocationAnnotation *locAnnotation = [[LocationAnnotation alloc] initWithCoordinate:theLocation.coordinate];
                
                // Set the properties of the annotation object
                locAnnotation.mTitle = ViolationStringFromBDMotionManagerViolationType(locObj.violation);
                locAnnotation.annotationType = BDAnnotationTypeUnsafeDriving;
                
                // Add the pin to map
                [self.mkMapView addAnnotation:locAnnotation];
            }
        }
    }
}

- (void)setupRouteAnnotation {
    // first create the route annotation, so it does not draw on top of the other annotations.
    NSMutableArray *pointArray = [[NSMutableArray alloc] init];
    
    // Loop through each data object and get the long and lat
    for (BDLocData *locObj in _locDataArray) {
        CLLocation *theLocation = [[CLLocation alloc] initWithLatitude:locObj.latitude longitude:locObj.longitude];
        [pointArray addObject:theLocation];
    }
    
    // If we have points, draw them as a route
    if (pointArray && [pointArray count] > 0) {
        
        // Create and add the route annotation
        self.routeAnnotation = [[CSRouteAnnotation alloc] initWithPoints:pointArray];
        [self.mkMapView addAnnotation:self.routeAnnotation];
        
        // Center map on route
        [self.mkMapView setRegion:self.routeAnnotation.region animated:YES];
        
    }
}

- (void)centerOnUserLoc {
    // Update the view area to center on the users current location
    MKCoordinateRegion region = self.mkMapView.region;
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.001f;
    region.span.latitudeDelta = 0.001f;
    [self.mkMapView setRegion:region animated:YES];
}

#pragma mark -
#pragma mark mapView delegate functions

/**
 Add annotation to map
 */
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.animatesDrop=NO;
    annView.canShowCallout = YES;
    //annView.calloutOffset = CGPointMake(-5, 5);
    
    // if it is the route annotation
    if([annotation isKindOfClass:[CSRouteAnnotation class]]) {
        MKAnnotationView* annotationView = nil;
        if(nil == annotationView) {
            CSRouteView* routeView = [[CSRouteView alloc] initWithFrame:CGRectMake(0, 0, self.mkMapView.frame.size.width, self.mkMapView.frame.size.height)];
            
            routeView.annotation = self.routeAnnotation;
            routeView.mapView = self.mkMapView;
            self.theRouteView = routeView;
            
            annotationView = routeView;
            return annotationView;
        }
    }  else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // Do nothing if it is the user location
        return nil;
    } else { // If it is a location data pin, create it
        LocationAnnotation *locAnnnoatation = (LocationAnnotation *)annotation;
        
        // Only create a pin if it is unsafe driving
        if (locAnnnoatation.annotationType > BDAnnotationTypeNormalDriving) {
            annView.animatesDrop=YES;
            annView.pinTintColor = MKPinAnnotationView.redPinColor;
        }
    }
    
    return annView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"Annotation Selected");
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // turn off the view of the route as the map is chaning regions. This prevents
    // the line from being displayed at an incorrect position on the map during the
    // transition.
    if (self.theRouteView) {
        self.theRouteView.hidden = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // re-enable and re-poosition the route display.
    if (self.theRouteView){
        self.theRouteView.hidden = NO;
        [self.theRouteView regionChanged];
    }
    
}

#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
    
    if (_locationManager != nil) {
        [_locationManager setDesiredAccuracy:self.locationAccuracy];
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:self.locationAccuracy];
    [_locationManager setDelegate:self];
    
    return _locationManager;
}


/**
 Keep updating the location on the map
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
//    if (!self.isPolling) {
//        self.userLocAnnotation = self.mkMapView.userLocation;
//        self.userLocation = self.userLocAnnotation.location.coordinate;
//    }
}

/**
 Display an error if location manager fails
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"self.locationManager failed!");
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle: @"Error: Your Location"
                               message: @"self.locationManager failed.  We do not know where we are."
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
    [errorAlert show];
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}

@end

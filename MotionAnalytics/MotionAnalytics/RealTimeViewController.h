//
//  FirstViewController.h
//  MotionAnalytics
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RealTimeViewController : UIViewController <MKMapViewDelegate,  CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextField *speedField;
@property (strong, nonatomic) IBOutlet UITextView *logView;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end


//
//  ViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *startStopButton;
@property (strong, nonatomic) IBOutlet UITextField *driverId;
@property (strong, nonatomic) IBOutlet UITextField *sensorId;
@property (strong, nonatomic) IBOutlet UITextField *load;
@property (strong, nonatomic) IBOutlet UITextView *logView;
@property (nonatomic, strong) CLLocationManager *locationManager;       // The location manager

@end


//
//  ViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ActiveTripViewController : UIViewController <CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager *locationManager;       // The location manager
@property (strong, nonatomic) IBOutlet UIView *circleBorderView;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;
@property (strong, nonatomic) IBOutlet UILabel *scoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *starsLbl;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIButton *finishedBtn;

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)tripFinishedBtnPressed:(id)sender;


@end


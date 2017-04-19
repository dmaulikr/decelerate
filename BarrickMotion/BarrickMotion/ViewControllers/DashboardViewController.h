//
//  DashboardViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-04-18.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *navigationBarView;

@property (strong, nonatomic) IBOutlet UILabel *driverLevelLbl;
@property (strong, nonatomic) IBOutlet UILabel *totalStarsLbl;

@property (strong, nonatomic) IBOutlet UILabel *averageScoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *scoreSubtitleLbl;

@property (strong, nonatomic) IBOutlet UILabel *speedScoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *speedSubtitleLbl;

@property (strong, nonatomic) IBOutlet UILabel *accelerationScoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *accelerationSubtitleLbl;

@property (strong, nonatomic) IBOutlet UILabel *turningSpeedScoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *turningSpeedSubtitleLbl;

@property (strong, nonatomic) IBOutlet UILabel *stoppingScoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *stoppingSubtitleLbl;

@property (strong, nonatomic) IBOutlet UIButton *startTripBtn;

- (IBAction)startTripBtnPressed:(id)sender;

@end

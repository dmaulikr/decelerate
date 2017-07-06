//
//  ViewController.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDMotionManager.h"

/**
 * View and controller for alerting driver of violations/score while driving during an active trip
 */
@interface ActiveTripViewController : UIViewController <BDMotionManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *circleBorderView;
@property (strong, nonatomic) IBOutlet UILabel *statusLbl;
@property (strong, nonatomic) IBOutlet UILabel *scoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *starsLbl;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIButton *finishedBtn;

// Return to previous screen
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)tripFinishedBtnPressed:(id)sender;


@end


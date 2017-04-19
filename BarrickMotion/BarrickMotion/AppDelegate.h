//
//  AppDelegate.h
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

- (CMMotionManager *)sharedManager;

- (NSInteger)activeTabIndex;
- (void)changeActiveTab:(NSInteger)tabIndex;

@end


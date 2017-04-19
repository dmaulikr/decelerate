//
//  AppDelegate.m
//  BarrickMotion
//
//  Created by Kevin Hunt on 2017-03-04.
//  Copyright © 2017 Prophet Studios. All rights reserved.
//

#import "AppDelegate.h"
#import "BarrickDataManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    CMMotionManager *_motionManager;
    UITabBarController *_tabBarController;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Initialize the motion manager for the app and keep the instance
    _motionManager  = [[CMMotionManager alloc] init];
    
    // Initialzie the Data Manager
    [[BarrickDataManager sharedDataManager] initializeWithLocalData];
    
    // Initialize the tab bar controller object
    _tabBarController = (UITabBarController *)[[self window] rootViewController];
    [_tabBarController setSelectedIndex:0];
    [_tabBarController setDelegate:self];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helper Methods

- (CMMotionManager *)sharedManager {
    return _motionManager;
}

- (NSInteger)activeTabIndex {
    return _tabBarController.selectedIndex;
}

- (void)changeActiveTab:(NSInteger)tabIndex {
    [_tabBarController setSelectedIndex:tabIndex];
}

#pragma mark - UITabController delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

@end

//
//  AppDelegate.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 29/08/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "GameCenterManager.h"
#import "chartboostHelper.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[GameCenterManager sharedManager] setupManager];
    
    // GA
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-54104285-2"];
    
    // Parse & Push Analytics
    [Parse setApplicationId:@"jM57X9tbTvwKY6Q4F3wVr9VdyHl3hHGtPzYdDCg9"
                  clientKey:@"eqGB3koye2lFhKJFPLMxZAhA74MZqpJ5H1cm39xC"];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Forward Notification info for lauching app
    
    NSDictionary *pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(pushDict)
    {
        [self application:application didReceiveRemoteNotification:pushDict];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    // pause sprite kit
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Monitor FB App installs
    [FBSettings setDefaultAppID:@"351290125048336"];
    [FBAppEvents activateApp];
    
    // Initialize the Chartboost library
    chartboostHelper *chartboostHlp = [[chartboostHelper alloc] init];
    [chartboostHlp initChartboost];
    
    // resume sprite kit
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
    
    [[GameCenterManager sharedManager] setupManager];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    self.appID = [userInfo objectForKey:@"callApp"];
    self.promo = [[Promo alloc] init];
    
    if([application applicationState] == UIApplicationStateInactive)
    {
        if (self.appID) {
            // Analytics of Push openrate
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            [self.promo showAppStoreID:self.appID withView:self.window];
        }
    } else {
        if (self.appID) {
            // Analytics of Push openrate
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
            [self.promo showAlertForMessage:userInfo withTitle:@"Flappy Spikes" forAppStoreID:self.appID withView:self.window];
        }
    }
}

@end

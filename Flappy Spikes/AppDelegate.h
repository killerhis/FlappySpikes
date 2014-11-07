//
//  AppDelegate.h
//  Flappy Spikes
//
//  Created by Hicham Chourak on 29/08/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Parse/Parse.h>
#import <StoreKit/StoreKit.h>
#import "Promo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSNumber *appID;
@property (strong, nonatomic) Promo *promo;
@end

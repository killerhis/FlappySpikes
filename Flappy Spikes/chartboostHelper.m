//
//  chartboostHelper.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 30/10/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "chartboostHelper.h"
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>

@interface chartboostHelper () <ChartboostDelegate, CBNewsfeedDelegate>
@end

@implementation chartboostHelper

- (void)initChartboost
{
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"54528a89bfe0846de8931453" appSignature:@"7e91b560363ef1889d56b84188ce9a7d4c065aae" delegate:self];
}

- (void)showInterstitial
{
    // Show interstitial at location HomeScreen.
    [Chartboost showInterstitial:CBLocationHomeScreen];
}

@end

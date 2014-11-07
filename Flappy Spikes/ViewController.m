//
//  ViewController.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 29/08/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@implementation ViewController  {
    GADBannerView *bannerView_;
    UIImageView *highlighted_;
    float _deviceScale;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set GameCenter Manager Delegate
    [[GameCenterManager sharedManager] setDelegate:self];

    // Configure the view.
    SKView * skView = (SKView *)self.view;   
    
    if (!skView.scene) {
        
        // Load admob ads
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        bannerView_.adUnitID = @"ca-app-pub-2660521344509391/1609129805";
        bannerView_.rootViewController = self;
        bannerView_.center = CGPointMake(skView.bounds.size.width / 2, skView.bounds.size.height - (bannerView_.frame.size.height / 2));
        [self.view addSubview:bannerView_];
        [bannerView_ loadRequest:[GADRequest request]];
        
        // Create and configure the scene.
        self.scene = [GameScene sceneWithSize:skView.bounds.size];
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:self.scene];
        
        // create Promo ad
        //[self fetchPromoAd];
        self.promo = [[Promo alloc] init];
        [self.promo fetchPromoAdWithController:self];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController
{
    [self presentViewController:gameCenterLoginController animated:YES completion:nil];
}

@end

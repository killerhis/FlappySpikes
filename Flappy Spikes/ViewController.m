//
//  ViewController.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 29/08/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"

@implementation ViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set GameCenter Manager Delegate
    [[GameCenterManager sharedManager] setDelegate:self];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [GameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
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

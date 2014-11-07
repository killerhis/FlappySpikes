//
//  ViewController.h
//  Flappy Spikes
//

//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameCenterManager.h"
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>
#import "Promo.h"

@interface ViewController : UIViewController <GameCenterManagerDelegate>

@property (nonatomic) NSNumber *promoID;
@property (strong, nonatomic) NSNumber *appID;
@property (strong, nonatomic) PFFile *img;
@property (strong, nonatomic) UIButton *promoButton;
@property (strong, nonatomic) SKScene *scene;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView *promoView;
@property (strong, nonatomic) Promo *promo;

@end

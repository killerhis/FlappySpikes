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

@interface ViewController : UIViewController <GameCenterManagerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic) NSNumber *ID;
@property (strong, nonatomic) NSNumber *appID;
@property (strong, nonatomic) NSString *img;
@property (strong, nonatomic) UIButton *promoButton;
@property (strong, nonatomic) SKScene *scene;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView *promoView;
@end

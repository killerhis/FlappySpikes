//
//  Promo.h
//  Flappy Spikes
//
//  Created by Hicham Chourak on 31/10/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <Parse/Parse.h>

@interface Promo : NSObject <SKStoreProductViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView *promoView;
@property (nonatomic) NSNumber *appID;
@property (nonatomic) NSNumber *promoID;
@property (strong, nonatomic) PFFile *img;
@property (strong, nonatomic) UIButton *promoButton;
@property (strong, nonatomic) UIViewController *controller;
@property (nonatomic) BOOL promoAdVisibile;

- (void)showAppStoreID:(NSNumber *)appStoreID withView:(UIWindow *)window;
- (void)showAlertForMessage:(NSDictionary *)userInfo withTitle:(NSString *)title forAppStoreID:(NSNumber *)appStoreID withView:(UIWindow *)window;
- (void)fetchPromoAdWithController:(UIViewController *)controller;

@end

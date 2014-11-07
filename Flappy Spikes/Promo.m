//
//  Promo.m
//  Flappy Spikes
//
//  Created by Hicham Chourak on 31/10/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import "Promo.h"
#import <StoreKit/StoreKit.h>
#import "ViewController.h"

@implementation Promo {
    UIImageView *highlighted_;
    float _deviceScale;
}

#pragma mark - Method for Promo banner call inApp

- (void)fetchPromoAdWithController:(UIViewController *)controller
{
    // init for method call
    self.view = controller.view;
    self.controller = controller;
    self.promoAdVisibile = YES;
    
    // Load last shown ad
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long lastPromoID = [defaults integerForKey:@"lastPromoID"];
    
    PFQuery *promoClass = [PFQuery queryWithClassName:@"Promo"];
    [promoClass orderByDescending:@"createdAt"];
    
    [promoClass findObjectsInBackgroundWithBlock:^(NSArray *promoObjects, NSError *error) {
        
        if (!error) {
            
            self.promoID = promoObjects[0][@"promoID"];
            self.appID = promoObjects[0][@"appID"];
            
            if (lastPromoID != [self.promoID integerValue]) {
                [defaults setInteger:[self.promoID integerValue] forKey:@"lastPromoID"];
                [defaults synchronize];
                
                //image size
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                {
                    // Device is iPad
                    _deviceScale = 2.0f;
                    
                    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                        ([UIScreen mainScreen].scale == 2.0)) {
                        // Retina display
                        self.img = promoObjects[0][@"img_2xipad"];
                        
                    } else {
                        self.img = promoObjects[0][@"img_ipad"];
                    }
                    
                } else {
                    // Device is iPhone/iPod
                    _deviceScale = 1.0f;
                    
                    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                        ([UIScreen mainScreen].scale == 3.0)) {
                        // iPhone Plus display
                        self.img = promoObjects[0][@"img_3x"];
                    } else {
                        self.img = promoObjects[0][@"img_2x"];
                    }
                    
                }
                
                // download the image asynchronously
                [self.img getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UIImage *image = [UIImage imageWithData:data];
                        float scale = [UIScreen mainScreen].scale;
                        
                        self.promoView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
                        [self.view addSubview:self.promoView];
                        
                        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [backgroundButton setBackgroundColor:[UIColor blackColor]];
                        backgroundButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                        backgroundButton.alpha = 0.8;
                        [self.promoView addSubview:backgroundButton];
                        
                        self.promoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [self.promoButton addTarget:self action:@selector(openAppStore:) forControlEvents:UIControlEventTouchUpInside];
                        [self.promoButton setBackgroundImage:image forState:UIControlStateNormal];
                        self.promoButton.frame = CGRectMake((self.view.frame.size.width - (image.size.width/scale))/2, (self.view.frame.size.height - (image.size.height/scale))/2, image.size.width/scale, image.size.height/scale);
                        [self.promoView addSubview:self.promoButton];
                        
                        UIImage *openButtonTexture = [UIImage imageNamed:@"open_button.png"];
                        UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [openButton addTarget:self action:@selector(openAppStore:) forControlEvents:UIControlEventTouchUpInside];
                        [openButton setBackgroundImage:openButtonTexture forState:UIControlStateNormal];
                        openButton.frame = CGRectMake((self.view.frame.size.width - (image.size.width/scale))/2 + (image.size.width/scale) - openButtonTexture.size.width - 3*_deviceScale, (self.view.frame.size.height - (image.size.height/scale))/2 + ((image.size.height/scale) - (openButtonTexture.size.height) - 3*_deviceScale), openButtonTexture.size.width, openButtonTexture.size.height);
                        [self.promoView addSubview:openButton];
                        
                        UIImage *closeButtonTexture = [UIImage imageNamed:@"close_button.png"];
                        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [closeButton addTarget:self action:@selector(closePromoAd:) forControlEvents:UIControlEventTouchUpInside];
                        [closeButton setBackgroundImage:closeButtonTexture forState:UIControlStateNormal];
                        closeButton.frame = CGRectMake((self.view.frame.size.width - (image.size.width/scale))/2 + 3*_deviceScale, (self.view.frame.size.height - (image.size.height/scale))/2 + ((image.size.height/scale) - (closeButtonTexture.size.height) - 3*_deviceScale), closeButtonTexture.size.width, closeButtonTexture.size.height);
                        [self.promoView addSubview:closeButton];
                        
                    } else {
                        
                    }
                }];
            }
        } else {
            //NSLog(@"error fetching promo");
        }
    }];
}

- (void)openAppStore:(id)sender
{
    self.promoButton.userInteractionEnabled  = NO;
    
    highlighted_ = [[UIImageView alloc] initWithFrame:self.promoButton.frame];
    highlighted_.backgroundColor = [UIColor blackColor];
    highlighted_.alpha = 0.5f;
    [self.promoView addSubview:highlighted_];
    
    //Create and add the Activity Indicator to splashView
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.promoView addSubview:self.spinner];
    
    //switch to background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //back to the main thread for the UI call
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner startAnimating];
        });
        
        [self presentAppStoreForID:self.appID withDelegate:self andController:self.controller];
        
        //back to the main thread for the UI call
        
    });
}

- (void)closePromoAd:(id)sender
{
    [UIView animateWithDuration:0.5f animations:^{
        [self.promoView setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        self.promoView.hidden = YES;
        [self.promoView removeFromSuperview];
    }];
}

- (void)presentAppStoreForID:(NSNumber *)appStoreID withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate andController:(UIViewController *)controller
{
    SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
    storeController.delegate = delegate;
    
    [storeController loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier: appStoreID }
                               completionBlock:^(BOOL result, NSError *error) {
                                   
                                   if (result) {
                                       [controller presentViewController:storeController animated:YES completion:nil];
                                   } else {
                                       [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem opening the app store" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                                   }
                                   
                               }];
    
}

#pragma mark - Method for appstore call from Push Notifications

- (void)showAlertForMessage:(NSDictionary *)userInfo withTitle:(NSString *)title forAppStoreID:(NSNumber *)appStoreID withView:(UIWindow *)window
{
    // init for delegate
    self.window = window;
    self.appID = appStoreID;
    self.promoAdVisibile = NO;
    
    SKView *view = (SKView *)window.rootViewController.view;
    view.paused = YES;
    
    NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Show", nil];
    [alertView show];
    
}

- (void)showAppStoreID:(NSNumber *)appStoreID withView:(UIWindow *)window
{
    // init window for delegates
    self.window = window;
    self.promoAdVisibile = NO;
    
    // Pause Screen
    //SKView *view = (SKView *)window.rootViewController.view;
    //view.paused = YES;
    
    // Create view
    self.promoView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [window.rootViewController.view addSubview:self.promoView];
    
    // Create transparrent background button
    UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backgroundButton setBackgroundColor:[UIColor blackColor]];
    backgroundButton.frame = CGRectMake(0, 0, window.rootViewController.view.frame.size.width, window.rootViewController.view.frame.size.height);
    backgroundButton.alpha = 0.8;
    [self.promoView addSubview:backgroundButton];
    
    //Create and add the Activity Indicator to splashView
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(window.rootViewController.view.frame.size.width/2, window.rootViewController.view.frame.size.height/2);
    [self.promoView addSubview:self.spinner];
    
    //switch to background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //back to the main thread for the UI call
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner startAnimating];
        });
        
        [self presentAppStoreForID:appStoreID withDelegate:self andView:window];
        
        //back to the main thread for the UI call
        
    });
}

- (void)presentAppStoreForID:(NSNumber *)appStoreID withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate andView:(UIWindow *)window
{
    SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
    storeController.delegate = delegate;
    
    [storeController loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier: appStoreID }
                               completionBlock:^(BOOL result, NSError *error) {
                                   
                                   if (result) {
                                       [window.rootViewController presentViewController:storeController animated:YES completion:nil];
                                   } else {
                                       [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem opening the app store" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                                   }
                                   
                               }];
    
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self showAppStoreID:self.appID withView:self.window];
        //[self presentAppStoreForID:self.appID withDelegate:self];
        //[self showAppStorewithID:self.appID];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    });
    
    if (self.promoAdVisibile) {
        self.promoButton.userInteractionEnabled = YES;
        [highlighted_ removeFromSuperview];
    } else {
        [self.promoView removeFromSuperview];
        
        SKView *view = (SKView *)self.window.rootViewController.view;
        view.paused = NO;
        
    }
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

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
        
        // create subview
        [self fetchPromoAd];
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

#pragma mark - Promo

- (void)fetchPromoAd
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastPromoID = [defaults integerForKey:@"lastPromoID"];
    
    NSURL *apiUrl = [[NSURL alloc] initWithString:@"http://api.hieshimi.com/008/promo/"];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:apiUrl] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error");
        } else {
            NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSArray *promo = [result valueForKeyPath:@"promo"];
            
            self.ID = [[promo objectAtIndex:0] objectForKey:@"ID"];
            self.appID = [[promo objectAtIndex:0] objectForKey:@"appID"];
            self.img = [[promo objectAtIndex:0] objectForKey:@"img"];
            
            if (lastPromoID != [self.ID integerValue]) {
                [defaults setInteger:[self.ID integerValue] forKey:@"lastPromoID"];
                [defaults synchronize];
                
                NSString *imageUrl = [self.img substringToIndex:[self.img length]-4];
                
                //image size
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                {
                    // Device is iPad
                    _deviceScale = 2.0f;
                    
                    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                        ([UIScreen mainScreen].scale == 2.0)) {
                        // Retina display
                        
                        self.img = [NSString stringWithFormat:@"%@@2x~ipad.jpg", imageUrl];
                        
                    } else {
                        self.img = [NSString stringWithFormat:@"%@~ipad.jpg", imageUrl];
                    }
                    
                } else {
                    // Device is iPhone/iPod
                    _deviceScale = 1.0f;
                    
                    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
                        ([UIScreen mainScreen].scale == 3.0)) {
                        // iPhone Plus display
                        self.img = [NSString stringWithFormat:@"%@@3x.jpg", imageUrl];
                    } else {
                        self.img = [NSString stringWithFormat:@"%@@2x.jpg", imageUrl];
                    }
                    
                }
                
                // download the image asynchronously
                [self downloadImageWithURL:[NSURL URLWithString:self.img] completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        
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
        
        [self presentAppStoreForID:self.appID withDelegate:self];
        
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

- (void)presentAppStoreForID:(NSNumber *)appStoreID withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate
{
    SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
    storeController.delegate = delegate;
    
    [storeController loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier: appStoreID }
                               completionBlock:^(BOOL result, NSError *error) {
                                   
                                   if (result) {
                                       [self presentViewController:storeController animated:YES completion:nil];
                                   } else {
                                       [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There was a problem opening the app store" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                                   }
                                   
                               }];
    
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   
                                   if (image == nil)
                                   {
                                       completionBlock(NO,nil);
                                   } else {
                                       completionBlock(YES,image);
                                   }
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}


#pragma mark - SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    });
    
    self.promoButton.userInteractionEnabled = YES;
    [highlighted_ removeFromSuperview];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

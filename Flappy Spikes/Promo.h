//
//  Promo.h
//  Flappy Spikes
//
//  Created by Hicham Chourak on 31/10/14.
//  Copyright (c) 2014 Hicham Chourak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Promo : NSObject

@property (nonatomic) NSNumber *ID;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *img;

- (void)fetchPromoAd;

@end

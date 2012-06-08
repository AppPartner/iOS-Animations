//
//  RZCircleSitckerHUD.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllablePageFlipper.h"

typedef void (^HUDDismissBlock)();

@interface RZCircleSitckerHUD : UIView <CPFlipperDelegate>

@property (assign, nonatomic) UIColor *hudColor;
@property (assign, nonatomic) UIColor *spinnerColor;
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) BOOL overlayOnly;

- (id)initWithRadius:(CGFloat)radius 
     backgroundColor:(UIColor*)bgColor
            hudColor:(UIColor*)hudColor
        spinnerColor:(UIColor*)spinnerColor;

- (void)presentInView:(UIView*)view withFold:(BOOL)fold;
- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated;

@end

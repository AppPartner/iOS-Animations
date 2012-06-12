//
//  RZLoadingHUD.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllablePageFlipper.h"

typedef void (^HUDDismissBlock)();

typedef enum {
    kRZHudStyle_Circle,
    kRZHudStyle_Box,
    kRZHudStyle_Overlay
} RZHudStyle;

@interface RZLoadingHUD : UIView <CPFlipperDelegate>

@property (assign, nonatomic) RZHudStyle hudStyle;

@property (strong, nonatomic) UIColor *overlayColor;
@property (strong, nonatomic) UIColor *hudColor;
@property (strong, nonatomic) UIColor *spinnerColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;

@property (assign, nonatomic) CGFloat hudAlpha;
@property (assign, nonatomic) CGFloat shadowAlpha;

// these apply to circle hud style only
@property (assign, nonatomic) CGFloat circleRadius;

// these apply to box hud style only
@property (assign, nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIColor* labelColor;
@property (strong, nonatomic) NSString* labelText;

- (id)initWithStyle:(RZHudStyle)style
       overlayColor:(UIColor*)overlayColor
           hudColor:(UIColor*)hudColor
       spinnerColor:(UIColor*)spinnerColor;

- (void)presentInView:(UIView*)view withFold:(BOOL)fold;
- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated;

@end

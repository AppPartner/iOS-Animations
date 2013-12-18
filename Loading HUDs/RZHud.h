//
//  RZHud.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllablePageFlipper.h"

typedef void (^HUDDismissBlock)();

typedef enum {
    RZHudStyleCircle,
    RZHudStyleBoxInfo,
    RZHudStyleBoxLoading,
    RZHudStyleOverlay
} RZHudStyle;

typedef enum {
    RZHudAnimationMaskFade = 1,
    RZHudAnimationMaskZoom = 2
} RZHudAnimationMask;

@interface RZHud : UIView <CPFlipperDelegate, UIAppearance>

/// @name Style properties
@property (strong, nonatomic) UIView  *customView       UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *overlayColor     UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *hudColor         UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *spinnerColor     UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *borderColor      UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat borderWidth       UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat shadowAlpha       UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) NSArray *imageViewAnimationArray      UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat imageViewAnimationDuration    UI_APPEARANCE_SELECTOR;

// these apply to box hud style only
@property (assign, nonatomic) CGFloat   cornerRadius    UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor   *labelColor     UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont    *labelFont      UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSString  *labelText      UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) RZHudAnimationMask presentationStyle UI_APPEARANCE_SELECTOR;

// these apply to circle hud style only
@property (assign, nonatomic) CGFloat circleRadius;

@property (assign, nonatomic) BOOL blocksTouches;

- (id)initWithStyle:(RZHudStyle)style;
- (void)presentInView:(UIView*)view withFold:(BOOL)fold;
- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block;
- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated;

@end

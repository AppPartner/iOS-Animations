//
//  RZHud.h
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
